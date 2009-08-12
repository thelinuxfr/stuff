#!/usr/local/bin/php
<?php 
/*
	$Id: firewall_nat_server_edit.php 72 2006-02-10 11:13:01Z jdegraeve $
	part of m0n0wall (http://m0n0.ch/wall)
	
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
require("guiconfig.inc");

$pgtitle = array(gettext("Firewall"),gettext("NAT"),gettext("Edit Server NAT"));

if (!is_array($config['nat']['servernat'])) {
	$config['nat']['servernat'] = array();
}
nat_server_rules_sort();
$a_snat = &$config['nat']['servernat'];

$id = $_GET['id'];
if (isset($_POST['id']))
	$id = $_POST['id'];

if (isset($id) && $a_snat[$id]) {
	$pconfig['ipaddr'] = $a_snat[$id]['ipaddr'];
	$pconfig['descr'] = $a_snat[$id]['descr'];
}

if ($_POST) {
	
	unset($input_errors);
	$pconfig = $_POST;

	/* input validation */
	$reqdfields = explode(" ", "ipaddr");
	$reqdfieldsn = explode(",", "External IP address");
	
	do_input_validation($_POST, $reqdfields, $reqdfieldsn, &$input_errors);

	if (($_POST['ipaddr'] && !is_ipaddr($_POST['ipaddr']))) {
		$input_errors[] = "A valid external IP address must be specified.";
	}
	
	if ($_POST['ipaddr'] == $config['interfaces']['wan']['ipaddr'])
		$input_errors[] = "The WAN IP address may not be used in a Server NAT entry.";
	
	/* check for overlaps with other server NAT */
	foreach ($a_snat as $natent) {
		if (isset($id) && ($a_snat[$id]) && ($a_snat[$id] === $natent))
			continue;
		
		if ($_POST['ipaddr'] == $natent['ipaddr']) {
			$input_errors[] = "There is already a server NAT entry for the specified external IP address.";
			break;
		}
	}
	
	/* check for overlaps with 1:1 NAT */
	if (is_array($config['nat']['onetoone'])) {
		foreach ($config['nat']['onetoone'] as $natent) {
			if (check_subnets_overlap($_POST['ipaddr'], 32, $natent['external'], $natent['subnet'])) {
				$input_errors[] = "A 1:1 NAT mapping overlaps with the specified external IP address.";
				break;
			}
		}
	}

	if (!$input_errors) {
		$natent = array();
		$natent['ipaddr'] = $_POST['ipaddr'];
		$natent['descr'] = $_POST['descr'];
		
		if (isset($id) && $a_snat[$id]) {
			/* modify all inbound NAT rules with this address */
			for ($i = 0; isset($config['nat']['rule'][$i]); $i++) {
				if ($config['nat']['rule'][$i]['external-address'] == $a_snat[$id]['ipaddr'])
					$config['nat']['rule'][$i]['external-address'] = $natent['ipaddr'];
			}
			$a_snat[$id] = $natent;
		} else
			$a_snat[] = $natent;
		
		touch($d_natconfdirty_path);
		
		write_config();
		
		header("Location: firewall_nat_server.php");
		exit;
	}
}
?>
<?php include("fbegin.inc"); ?>
<?php if ($input_errors) print_input_errors($input_errors); ?>
            <form action="firewall_nat_server_edit.php" method="post" name="iform" id="iform">
              <table width="100%" border="0" cellpadding="6" cellspacing="0">
                <tr> 
                  <td width="22%" valign="top" class="vncellreq">External IP address</td>
                  <td width="78%" class="vtable"> 
                    <?=$mandfldhtml;?><input name="ipaddr" type="text" class="formfld" id="ipaddr" size="20" value="<?=htmlspecialchars($pconfig['ipaddr']);?>">
                    </td>
                </tr>
                <tr> 
                  <td width="22%" valign="top" class="vncell">Description</td>
                  <td width="78%" class="vtable"> 
                    <input name="descr" type="text" class="formfld" id="descr" size="40" value="<?=htmlspecialchars($pconfig['descr']);?>"> 
                    <br> <span class="vexpl">You may enter a description here 
                    for your reference (not parsed).</span></td>
                </tr>
                <tr> 
                  <td width="22%" valign="top">&nbsp;</td>
                  <td width="78%"> 
                    <input name="Submit" type="submit" class="formbtn" value="Save"> 
                    <?php if (isset($id) && $a_snat[$id]): ?>
                    <input name="id" type="hidden" value="<?=$id;?>"> 
                    <?php endif; ?>
                  </td>
                </tr>
              </table>
</form>
<?php include("fend.inc"); ?>
