#!/usr/local/bin/php
<?php 
/*
	$Id: firewall_nat_1to1.php 72 2006-02-10 11:13:01Z jdegraeve $
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

$pgtitle = array(gettext("Firewall"),gettext("NAT"),gettext("1:1"));

if (!is_array($config['nat']['onetoone'])) {
	$config['nat']['onetoone'] = array();
}
$a_1to1 = &$config['nat']['onetoone'];
nat_1to1_rules_sort();

if ($_POST) {

	$pconfig = $_POST;

	if ($_POST['apply']) {
		$retval = 0;
		if (!file_exists($d_sysrebootreqd_path)) {
			config_lock();
			$retval |= filter_configure();
			$retval |= services_proxyarp_configure();
			config_unlock();
		}
		$savemsg = get_std_save_message($retval);
		
		if ($retval == 0) {
			if (file_exists($d_natconfdirty_path))
				unlink($d_natconfdirty_path);
			if (file_exists($d_filterconfdirty_path))
				unlink($d_filterconfdirty_path);
			if (file_exists($d_proxyarpdirty_path))
				unlink($d_proxyarpdirty_path);
		}
	}
}

if ($_GET['act'] == "del") {
	if ($a_1to1[$_GET['id']]) {
		unset($a_1to1[$_GET['id']]);
		write_config();
		touch($d_natconfdirty_path);
		header("Location: firewall_nat_1to1.php");
		exit;
	}
}
?>
<?php include("fbegin.inc"); ?>
<form action="firewall_nat_1to1.php" method="post">
<?php if ($savemsg) print_info_box($savemsg); ?>
<?php if (file_exists($d_natconfdirty_path)): ?><p>
<?php print_info_box_np("The NAT configuration has been changed.<br>You must apply the changes in order for them to take effect.");?><br>
<input name="apply" type="submit" class="formbtn" id="apply" value="Apply changes"></p>
<?php endif; ?>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td class="tabnavtbl">
  <ul id="tabnav">
				<li class="tabinact"><a href="firewall_nat.php" title="<?=gettext("Reload page");?>"><span><?=gettext("Inbound");?></span></a></li>
				<li class="tabinact"><a href="firewall_nat_server.php"><span><?=gettext("Server NAT");?></span></a></li>
				<li class="tabact"><a href="firewall_nat_1to1.php"><span><?=gettext("1:1");?></span></a></li>
				<li class="tabinact"><a href="firewall_nat_out.php"><span><?=gettext("Outbound");?></span></a></li>
  </ul>
  </td></tr>
  <tr> 
    <td class="tabcont">
              <table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr> 
				  <td width="10%" class="listhdrr">Interface</td>
                  <td width="20%" class="listhdrr">External IP</td>
                  <td width="20%" class="listhdrr">Internal IP</td>
                  <td width="40%" class="listhdr">Description</td>
                  <td width="10%" class="list"></td>
				</tr>
			  <?php $i = 0; foreach ($a_1to1 as $natent): ?>
                <tr> 
				  <td class="listlr">
                  <?php
					if (!$natent['interface'] || ($natent['interface'] == "wan"))
						echo "WAN";
					else
						echo htmlspecialchars($config['interfaces'][$natent['interface']]['descr']);
				  ?>
                  </td>
                  <td class="listr"> 
                    <?php echo $natent['external'];
					if ($natent['subnet']) echo "/" . $natent['subnet']; ?>
                  </td>
                  <td class="listr"> 
                    <?php echo $natent['internal'];
					if ($natent['subnet']) echo "/" . $natent['subnet']; ?>
                  </td>
                  <td class="listbg"> 
                    <?=htmlspecialchars($natent['descr']);?>&nbsp;
                  </td>
                  <td class="list" nowrap> <a href="firewall_nat_1to1_edit.php?id=<?=$i;?>"><img src="e.png" title="edit mapping" width="17" height="17" border="0"></a>
                     &nbsp;<a href="firewall_nat_1to1.php?act=del&id=<?=$i;?>" onclick="return confirm('Do you really want to delete this mapping?')"><img src="x.png" title="delete mapping" width="17" height="17" border="0"></a></td>
				</tr>
			  <?php $i++; endforeach; ?>
                <tr> 
                  <td class="list" colspan="4"></td>
                  <td class="list"> <a href="firewall_nat_1to1_edit.php"><img src="plus.png" title="add mapping" width="17" height="17" border="0"></a></td>
				</tr>
              </table><br>
			  	<span class="vexpl"><span class="red"><strong>Note:<br>
                </strong></span>Depending on the way your WAN connection is setup, you may also need <a href="services_proxyarp.php">proxy ARP</a>.</span>
</td>
</tr>
</table>
</form>
<?php include("fend.inc"); ?>
