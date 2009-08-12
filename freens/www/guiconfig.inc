<?php
/*
	guiconfig.inc
	part of FreeNAS (http://www.freenas.org)
	Copyright (C) 2005-2009 Olivier Cochard-Labbe <olivier@freenas.org>.
	All rights reserved.

	Based on m0n0wall (http://m0n0.ch/wall)
	Copyright (C) 2003-2006 Manuel Kasper <mk@neon1.net>.
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	1. Redistributions of source code must retain the above copyright notice,
	   this list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/

/* make sure nothing is cached */
if (!$omit_nocacheheaders) {
	header("Expires: 0");
	header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
	header("Cache-Control: no-store, no-cache, must-revalidate");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");
}

/* parse the configuration and include all configuration functions */
require_once("config.inc");
require_once("functions.inc");
require_once("rc.inc");
require_once("wui.inc");
require_once("updatenotify.inc");

/* Set the current language */
system_language_load();

$d_fwupenabled_path = $g['varrun_path'] . "/fwup.enabled";
$d_firmwarelock_path = $g['varrun_path'] . "/firmware.lock";
$d_sysrebootreqd_path = $g['varrun_path'] . "/sysreboot.reqd";
$d_upnpconfdirty_path = $g['varrun_path'] . "/upnp.conf.dirty";
$d_packagesconfdirty_path = $g['varrun_path'] . "/packages.conf.dirty";

$d_natconfdirty_path = $g['varrun_path'] . "/nat.conf.dirty";
$d_filterconfdirty_path = $g['varrun_path'] . "/filter.conf.dirty";
$d_ipsecconfdirty_path = $g['varrun_path'] . "/ipsec.conf.dirty";
$d_shaperconfdirty_path = $g['varrun_path'] . "/shaper.conf.dirty";
$d_pptpuserdirty_path = $g['varrun_path'] . "/pptpd.user.dirty";
$d_dnsmasqdirty_path = $g['varrun_path'] . "/dnsmasq.dirty";
$d_staticmapsdirty_path = $g['varrun_path'] . "/staticmaps.dirty";
$d_staticroutesdirty_path = $g['varrun_path'] . "/staticroutes.dirty";
$d_aliasesdirty_path = $g['varrun_path'] . "/aliases.dirty";
$d_proxyarpdirty_path = $g['varrun_path'] . "/proxyarp.dirty";
$d_fwupenabled_path = $g['varrun_path'] . "/fwup.enabled";
$d_firmwarelock_path = $g['varrun_path'] . "/firmware.lock";
$d_sysrebootreqd_path = $g['varrun_path'] . "/sysreboot.reqd";
$d_passthrumacsdirty_path = $g['varrun_path'] . "/passthrumacs.dirty";
$d_allowedipsdirty_path = $g['varrun_path'] . "/allowedips.dirty";

if (file_exists($d_firmwarelock_path)) {
	if (!$d_isfwfile) {
		header("Location: system_firmware.php");
		exit;
	} else {
		return;
	}
}

/* Reserverd login names */
$reservedlogin = array("root", "toor", "daemon", "operator", "bin", "tty", "kmem", "www", "nobody", "ftp", "sshd");

/* TCP flags */
$tcpflags = array("fin", "syn", "rst", "psh", "ack", "urg");

/* platforms that support firmware updating */
$fwupplatforms = array('net45xx', 'net48xx', 'embedded', 'wrap', 'full');

function do_input_validation($postdata, $reqdfields, $reqdfieldsn, $input_errors) {
	/* check for bad control characters */
	foreach ($postdata as $pn => $pd) {
		if (is_string($pd) && preg_match("/[\\x00-\\x08\\x0b\\x0c\\x0e-\\x1f]/", $pd)) {
			$input_errors[] = sprintf( gettext("The attribute '%s' contains invalid characters."), $pn);
		}
	}

	for ($i = 0; $i < count($reqdfields); $i++) {
		if (!isset($postdata[$reqdfields[$i]]) || ($postdata[$reqdfields[$i]] === "")) {
			$input_errors[] = sprintf( gettext("The attribute '%s' is required."), $reqdfieldsn[$i]);
		}
	}
}

/* Validate attribute type. */
function do_input_validation_type($postdata, $reqdfields, $reqdfieldsn, $reqdfieldst, $input_errors) {
	/* Validate type. */
	for ($i = 0; $i < count($reqdfields); $i++) {
		if (isset($postdata[$reqdfields[$i]]) && ($postdata[$reqdfields[$i]] !== "")) {
			$valid = false;
			$message = "";

			switch($reqdfieldst[$i]) {
				case 'string':				$valid = is_string($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' must be a string."), $reqdfieldsn[$i]);
															break;
				case 'numeric':				$valid = is_numeric($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' must be a number."), $reqdfieldsn[$i]);
															break;
				case 'numericint':		$valid = is_numericint($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' must be a number."), $reqdfieldsn[$i]);
															break;
				case 'ipaddr':				$valid = is_ipaddr($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' is no valid IP address."), $reqdfieldsn[$i]);
															break;
				case 'macaddr': 			$valid = is_macaddr($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' is no valid MAC address."), $reqdfieldsn[$i]);
															break;
				case 'subnet': 				$valid = is_subnet($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' is no valid subnet mask."), $reqdfieldsn[$i]);
															break;
				case 'domain': 				$valid = is_domain($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' contains invalid characters and is no valid domain name."), $reqdfieldsn[$i]);
															break;
				case 'netbios': 			$valid = is_netbios($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' contains invalid characters and is no valid NetBIOS name."), $reqdfieldsn[$i]);
															break;
				case 'hostname': 			$valid = is_hostname($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' contains invalid characters and is no valid host name."), $reqdfieldsn[$i]);
															break;
				case 'workgroup': 		$valid = is_workgroup($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' contains invalid characters and is no valid workgroup name."), $reqdfieldsn[$i]);
															break;
				case 'filemode': 			$valid = is_filemode($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' is no valid file mode mask."), $reqdfieldsn[$i]);
															break;
				case 'mtu': 					$valid = is_mtu($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' is invalid."), $reqdfieldsn[$i]);
															break;
				case 'port': 					$valid = is_port($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' is an invalid port number."), $reqdfieldsn[$i]);
															break;
				case 'password':			$valid = is_validpassword($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' contains the illegal character ':' and is no valid password."), $reqdfieldsn[$i]);
															break;
				case 'certificate':		$valid = is_valid_certificate($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' does not appear to be a valid certificate."), $reqdfieldsn[$i]);
															break;
				case 'privatekey':		$valid = is_valid_privatekey($postdata[$reqdfields[$i]], "RSA");
															$message = sprintf( gettext("The attribute '%s' does not appear to be a valid private key."), $reqdfieldsn[$i]);
															break;
				case 'privatedsakey':	$valid = is_valid_privatekey($postdata[$reqdfields[$i]], "DSA");
															$message = sprintf( gettext("The attribute '%s' does not appear to be a valid private %s key."), $reqdfieldsn[$i], "DSA");
															break;
				case 'alias':					$valid = is_validaliasname($postdata[$reqdfields[$i]]);
															$message = sprintf( gettext("The attribute '%s' may only consist of the characters a-z, A-Z, 0-9."), $reqdfieldsn[$i]);
															break;
				case 'time':					$valid = (FALSE !== strptime($postdata[$reqdfields[$i]], "%H:%M:%S"));
															$message = sprintf( gettext("The attribute '%s' is no valid time."), $reqdfieldsn[$i]);
															break;
				case 'array':					$valid = (is_array($postdata[$reqdfields[$i]]) && !empty($postdata[$reqdfields[$i]]));
															$message = sprintf( gettext("The attribute '%s' must contain at least one entry."), $reqdfieldsn[$i]);
															break;
			}
			if (!$valid) {
				$input_errors[] = $message;
			}
		}
	}
}

function do_input_validate_synctime($postdata, $input_errors) {
	$data = array();
	$data[] = array("field" => "minute", "all" => "all_mins", "text" => "minutes");
	$data[] = array("field" => "hour", "all" => "all_hours", "text" => "hours");
	$data[] = array("field" => "day", "all" => "all_days", "text" => "days");
	$data[] = array("field" => "month", "all" => "all_months", "text" => "months");
	$data[] = array("field" => "weekday", "all" => "all_weekdays", "text" => "week days");

	foreach ($data as $datak => $datav) {
		if (!$postdata[$datav['all']]) {
			if (!isset($postdata[$datav['field']]) || empty($postdata[$datav['field']])) {
				$input_errors[] = sprintf(gettext("You have to select at least one item for '%s'."), $datav['text']);
			}
		}
	}
}

function print_input_errors($input_errors) {
	echo "  <div id='errorbox'>\n";
	echo "    <table border=\"0\" cellspacing=\"0\" cellpadding=\"4\" width=\"100%\">\n";
	echo "      <tr>\n";
	echo "        <td class=\"icon\" align=\"center\" valign=\"top\"><img src=\"/err.png\"></td>\n";
	echo "        <td class=\"message\">\n";
	echo "          <p>" . gettext("The following input errors were detected").":\n";
	echo "            <ul>\n";
	foreach ($input_errors as $msg) {
		echo "              <li>{$msg}</li>\n";
	}
	echo "            </ul>\n";
	echo "          </p>\n";
	echo "        </td>\n";
	echo "      </tr>\n";
	echo "    </table>\n";
	echo "  </div>\n";
}

function print_info_box_np($msg) {
	echo "<table border=\"0\" cellspacing=\"0\" cellpadding=\"4\" width=\"100%\">\n";
	echo "<tr><td bgcolor=\"#687BA4\" align=\"center\" valign=\"top\" width=\"36\"><img src=\"/exclam.png\" width=\"28\" height=\"32\"></td>\n";
	echo "<td bgcolor=\"#D9DEE8\" style=\"padding-left: 8px\">";
	echo $msg;
	echo "</td></tr></table>";
}

function verify_gzip_file($fname) {
	$returnvar = mwexec("/usr/bin/gzip -t " . escapeshellarg($fname), true);
	if ($returnvar != 0)
		return 0;
	else
		return 1;
}

function print_core_box($type, $msg) {
	switch ($type) {
		case "info":
			$id = "infobox";
			$img = "exclam.png";
			break;
		case "warning":
			$id = "warningbox";
			$img = "warn.png";
			break;
		case "error":
			$id = "errorbox";
			$img = "err.png";
			break;
	}

	echo "<div id='{$id}'>\n";
	echo "  <table border=\"0\" cellspacing=\"0\" cellpadding=\"4\" width=\"100%\">\n";
	echo "    <tr>\n";
	echo "      <td class=\"icon\" align=\"center\" valign=\"top\"><img src=\"/{$img}\"></td>\n";
	echo "      <td class=\"message\">{$msg}</td>\n";
	echo "    </tr>\n";
	echo "  </table>\n";
	echo "</div>\n";
}

function print_info_box($msg) {
	print_core_box("info", $msg);
}

function print_error_box($msg) {
	print_core_box("error", $msg);
}

function print_warning_box($msg) {
	print_core_box("warning", $msg);
}

function print_config_change_box() {
	$message = gettext("Apply changes");
	echo "<div id='applybox'>";
	print_info_box(gettext("The configuration has been changed.<br>You must apply the changes in order for them to take effect."));
	echo "<input name=\"apply\" type=\"submit\" class=\"formbtn\" id=\"apply\" value=\"{$message}\">";
	echo "</div>";
}

function format_bytes($bytes) {
	if ($bytes >= 1073741824) {
		return sprintf("%.2f GB", $bytes/1073741824);
	} else if ($bytes >= 1048576) {
		return sprintf("%.2f MB", $bytes/1048576);
	} else if ($bytes >= 1024) {
		return sprintf("%.0f KB", $bytes/1024);
	} else {
		return sprintf("%d bytes", $bytes);
	}
}

function get_std_save_message($ok) {
	global $d_sysrebootreqd_path;

	if ($ok == 0) {
		if (file_exists($d_sysrebootreqd_path)) {
			return sprintf( gettext("The changes have been saved. You have to <a href=%s>reboot</a> the system for the changes to take effect."), "reboot.php");
		}
		else {
			return gettext("The changes have been applied successfully.");
		}
	} else {
		return sprintf( gettext("Error: The changes could not be applied (error code %s)."), $ok);
	}
}

function html_inputbox($ctrlname, $title, $value, $desc, $required = false, $size = 40, $readonly = false) {
	$ctrl = new HTMLEditBox($ctrlname, $title, $value, $desc, $size);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_passwordbox($ctrlname, $title, $value, $desc, $required = false, $size = 20, $readonly = false) {
	$ctrl = new HTMLPasswordBox($ctrlname, $title, $value, $desc, $size);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_passwordconfbox($ctrlname, $ctrlnameconf, $title, $value, $valueconf, $desc, $required = false, $size = 20, $readonly = false) {
	$ctrl = new HTMLPasswordConfBox($ctrlname, $ctrlnameconf, $title, $value, $valueconf, $desc, $size);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_textarea($ctrlname, $title, $value, $desc, $required = false, $columns = 40, $rows = 5, $readonly = false, $wrap = true) {
	$ctrl = new HTMLTextArea($ctrlname, $title, $value, $desc, $columns, $rows);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->SetWrap($wrap);
	$ctrl->Render();
}

function html_filechooser($ctrlname, $title, $value, $desc, $path, $required = false, $size = 60, $readonly = false) {
	$ctrl = new HTMLFileChooser($ctrlname, $title, $value, $desc, $size);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->SetPath($path);
	$ctrl->Render();
}

function html_combobox($ctrlname, $title, $value, $options, $desc, $required = false, $readonly = false, $onclick = "") {
	$ctrl = new HTMLComboBox($ctrlname, $title, $value, $options, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->SetJSonClick($onclick);
	$ctrl->Render();
}

function html_mountcombobox($ctrlname, $title, $value, $desc, $required = false, $readonly = false) {
	$ctrl = new HTMLMountComboBox($ctrlname, $title, $value, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_timezonecombobox($ctrlname, $title, $value, $desc, $required = false, $readonly = false) {
	$ctrl = new HTMLTimeZoneComboBox($ctrlname, $title, $value, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_languagecombobox($ctrlname, $title, $value, $desc, $required = false, $readonly = false) {
	$ctrl = new HTMLLanguageComboBox($ctrlname, $title, $value, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_interfacecombobox($ctrlname, $title, $value, $desc, $required = false, $readonly = false) {
	$ctrl = new HTMLInterfaceComboBox($ctrlname, $title, $value, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_checkbox($ctrlname, $title, $checked, $caption = "", $desc = "", $required = false, $onclick = "") {
	$ctrl = new HTMLCheckBox($ctrlname, $title, $checked, $caption, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetJSonClick($onclick);
	$ctrl->Render();
}

function html_separator() {
	$ctrl = new HTMLSeparator();
	$ctrl->Render();
}

function html_titleline($title) {
	$ctrl = new HTMLTitleLine($title);
	$ctrl->Render();
}

function html_titleline_checkbox($ctrlname, $title, $value, $caption, $onclick = "") {
	$ctrl = new HTMLTitleLineCheckBox($ctrlname, $title, $value, $caption);
	$ctrl->SetJSonClick($onclick);
	$ctrl->Render();
}

function html_text($ctrlname, $title, $text) {
	$ctrl = new HTMLText($ctrlname, $title, $text);
	$ctrl->Render();
}

function html_remark($ctrlname, $title, $text) {
	$ctrl = new HTMLRemark($ctrlname, $title, $text);
	$ctrl->Render();
}

function html_listbox($ctrlname, $title, $value, $options, $desc, $required = false, $readonly = false, $onclick = "") {
	$ctrl = new HTMLListBox($ctrlname, $title, $value, $options, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->SetJSonClick($onclick);
	$ctrl->Render();
}

function html_ipv4addrbox($ctrlname, $ctrlnamenetmask, $title, $value, $valuenetmask, $desc, $required = false, $readonly = false) {
	$ctrl = new HTMLIPv4AddressBox($ctrlname, $ctrlnamenetmask, $title, $value, $valuenetmask, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_ipv6addrbox($ctrlname, $ctrlnamenetmask, $title, $value, $valuenetmask, $desc, $required = false, $readonly = false) {
	$ctrl = new HTMLIPv6AddressBox($ctrlname, $ctrlnamenetmask, $title, $value, $valuenetmask, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->Render();
}

function html_folderbox($ctrlname, $title, $value, $desc, $path, $required = false, $readonly = false) {
	$ctrl = new HTMLFolderBox($ctrlname, $title, $value, $desc);
	$ctrl->SetRequired($required);
	$ctrl->SetReadOnly($readonly);
	$ctrl->SetPath($path);
	$ctrl->Render();
}


/* MONOWALL */
function filter_rules_sort() {
	global $g, $config;
	
	/* mark each rule with the sequence number (to retain the order while sorting) */
	for ($i = 0; isset($config['filter']['rule'][$i]); $i++)
		$config['filter']['rule'][$i]['seq'] = $i;
	
	function filtercmp($a, $b) {
		if ($a['interface'] == $b['interface'])
			return $a['seq'] - $b['seq'];
		else
			return -strcmp($a['interface'], $b['interface']);
	}
	
	usort($config['filter']['rule'], "filtercmp");
	
	/* strip the sequence numbers again */
	for ($i = 0; isset($config['filter']['rule'][$i]); $i++)
		unset($config['filter']['rule'][$i]['seq']);
}

function nat_rules_sort() {
	global $g, $config;
	
	function natcmp($a, $b) {
		if ($a['external-address'] == $b['external-address']) {
			if ($a['protocol'] == $b['protocol']) {
				if ($a['external-port'] == $b['external-port']) {
					return 0;
				} else {
					return ($a['external-port'] - $b['external-port']);
				}
			} else {
				return strcmp($a['protocol'], $b['protocol']);
			}
		} else if (!$a['external-address'])
			return 1;
		else if (!$b['external-address'])
			return -1;
		else
			return ipcmp($a['external-address'], $b['external-address']);
	}
	
	usort($config['nat']['rule'], "natcmp");
}

function nat_1to1_rules_sort() {
	global $g, $config;
	
	function nat1to1cmp($a, $b) {
		return ipcmp($a['external'], $b['external']);
	}
	
	usort($config['nat']['onetoone'], "nat1to1cmp");
}

function nat_server_rules_sort() {
	global $g, $config;
	
	function natservercmp($a, $b) {
		return ipcmp($a['ipaddr'], $b['ipaddr']);
	}
	
	usort($config['nat']['servernat'], "natservercmp");
}

function nat_out_rules_sort() {
	global $g, $config;
	
	function natoutcmp($a, $b) {
		return strcmp($a['source']['network'], $b['source']['network']);
	}
	
	usort($config['nat']['advancedoutbound']['rule'], "natoutcmp");
}

function pptpd_users_sort() {
	global $g, $config;
	
	function usercmp($a, $b) {
		return strcasecmp($a['name'], $b['name']);
	}
	
	usort($config['pptpd']['user'], "usercmp");
}

function captiveportal_users_sort() {
	global $g, $config;
	
	function cpusercmp($a, $b) {
		return strcasecmp($a['name'], $b['name']);
	}
	
	usort($config['captiveportal']['user'], "cpusercmp");
}

function admin_groups_sort() {
	global $g, $config;
	
	function cpusercmp($a, $b) {
		return strcasecmp($a['name'], $b['name']);
	}
	
	usort($config['system']['group'], "cpusercmp");
}

function admin_users_sort() {
	global $g, $config;
	
	function cpusercmp($a, $b) {
		return strcasecmp($a['name'], $b['name']);
	}
	
	usort($config['system']['user'], "cpusercmp");
}

function staticroutes_sort() {
	global $g, $config;

	function staticroutecmp($a, $b) {
		return strcmp($a['network'], $b['network']);
	}

	usort($config['staticroutes']['route'], "staticroutecmp");
}

function hosts_sort() {
	global $g, $config;

	function hostcmp($a, $b) {
		if (strcasecmp($a['domain'], $b['domain']) == 0)
			return strcasecmp($a['host'], $b['host']);
		else
			return strcasecmp($a['domain'], $b['domain']);
	}

	usort($config['dnsmasq']['hosts'], "hostcmp");
}

function domainoverrides_sort() {
	global $g, $config;

	function domainoverridescmp($a, $b) {
		return strcasecmp($a['domain'], $b['domain']);
	}

	usort($config['dnsmasq']['domainoverrides'], "domainoverridescmp");
}

function staticmaps_sort($if) {
	global $g, $config;

	function staticmapcmp($a, $b) {
		return ipcmp($a['ipaddr'], $b['ipaddr']);
	}

	usort($config['dhcpd'][$if]['staticmap'], "staticmapcmp");
}

function aliases_sort() {
	global $g, $config;

	function aliascmp($a, $b) {
		return strcmp($a['name'], $b['name']);
	}

	usort($config['aliases']['alias'], "aliascmp");
}

function ipsec_mobilekey_sort() {
	global $g, $config;

	function mobilekeycmp($a, $b) {
		return strcmp($a['ident'][0], $b['ident'][0]);
	}

	usort($config['ipsec']['mobilekey'], "mobilekeycmp");
}

function proxyarp_sort() {
	global $g, $config;

	function proxyarpcmp($a, $b) {
		if (isset($a['network']))
			list($ast,$asn) = explode("/", $a['network']);
		else if (isset($a['range'])) {
			$ast = $a['range']['from'];
			$asn = 32;
		}
		if (isset($b['network']))
			list($bst,$bsn) = explode("/", $b['network']);
		else if (isset($b['range'])) {
			$bst = $b['range']['from'];
			$bsn = 32;
		}
		if (ipcmp($ast, $bst) == 0)
			return ($asn - $bsn);
		else
			return ipcmp($ast, $bst);
	}

	usort($config['proxyarp']['proxyarpnet'], "proxyarpcmp");
}

function passthrumacs_sort() {
	global $g, $config;

	function passthrumacscmp($a, $b) {
		return strcmp($a['mac'], $b['mac']);
	}
	
	usort($config['captiveportal']['passthrumac'],"passthrumacscmp");
}

function allowedips_sort() {
	global $g, $config;

	function allowedipscmp($a, $b) {
		return strcmp($a['ip'], $b['ip']);
	}
	
	usort($config['captiveportal']['allowedip'],"allowedipscmp");
}

function cpelements_sort() {
	global $g, $config;

	function cpelementscmp($a, $b) {
		return strcasecmp($a['name'], $b['name']);
	}
	
	usort($config['captiveportal']['element'],"cpelementscmp");
}

function wol_sort() {
	global $g, $config;

	function wolcmp($a, $b) {
		return strcmp($a['descr'], $b['descr']);
	}
	
	usort($config['wol']['wolentry'], "wolcmp");
}

function ipsec_ca_sort() {
	global $g, $config;

	function ipseccacmp($a, $b) {
		return strcmp($a['ident'], $b['ident']);
	}

	usort($config['ipsec']['cacert'], "ipseccacmp");
}

function pprint_address($adr) {
	global $specialnets;

	if (isset($adr['any'])) {
		$padr = "*";
	} else if ($adr['network']) {
		$padr = $specialnets[$adr['network']];
	} else {
		$padr = $adr['address'];
	}
	
	if (isset($adr['not']))
		$padr = "! " . $padr;
	
	return $padr;
}

function pprint_port($port) {
	global $wkports;

	$pport = "";
		
	if (!$port)
		echo "*";
	else {
		$srcport = explode("-", $port);
		if ((!$srcport[1]) || ($srcport[0] == $srcport[1])) {
			$pport = $srcport[0];
			if ($wkports[$srcport[0]]) {
				$pport .= " (" . $wkports[$srcport[0]] . ")";
			}
		} else
			$pport .= $srcport[0] . " - " . $srcport[1];
	}
	
	return $pport;
}
?>
