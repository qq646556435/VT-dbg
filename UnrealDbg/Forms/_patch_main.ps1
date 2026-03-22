$path = Join-Path $PSScriptRoot 'Main.pas'
$p = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

$repl = [ordered]@{
  'TForm1' = 'TConfigWnd'
  'RichEdit1' = 'memoLog1'
  'Label_SystemName' = 'lblSysName'
  'Label_SystemVer' = 'lblSysVer'
  'Label_CPU' = 'lblCpu'
  'EnterVTDebuggingMode' = 'btnAction1'
  'DbgListView' = 'listItems1'
  'OpenDialog1' = 'dlgOpen1'
  'DebuggerPopupMenu' = 'popMenu1'
  'StartDebuggerMenu' = 'mnuCmd1'
  'AddDebuggerMenu' = 'mnuCmd2'
  'DelDebuggerMenu' = 'mnuCmd3'
  'PageControl1' = 'pageMain1'
  'pgcConfrontation' = 'pageSub1'
  'TL_EnabledConfrontat' = 'chkOpt7'
  'TL_HandlerGetTickCountCheck' = 'chkOpt8'
  'TL_BlockResumeThread' = 'chkOpt9'
  'Image1' = 'imgPick1'
  'Label1' = 'lblDrag'
  'Label2' = 'lblNote'
  'CheckBox1' = 'chkFlag1'
  'CheckBox2' = 'chkFlag2'
  'CheckBox3' = 'chkFlag3'
  'CheckBox4' = 'chkFlag4'
  'CheckBox5' = 'chkFlag5'
  'CheckBox6' = 'chkFlag6'
  'GroupBox1' = 'grpBox1'
  'GroupBox2' = 'grpBox2'
  'GroupBox3' = 'grpBox3'
  'EnterVTDebuggingModeClick' = 'btnAction1Click'
  'StartDebuggerMenuClick' = 'mnuCmd1Click'
  'AddDebuggerMenuClick' = 'mnuCmd2Click'
  'DelDebuggerMenuClick' = 'mnuCmd3Click'
  'DbgListViewMouseDown' = 'listItems1MouseDown'
  'Image1MouseDown' = 'imgPick1MouseDown'
  'Image1MouseUp' = 'imgPick1MouseUp'
  'Image1MouseMove' = 'imgPick1MouseMove'
  'TL_EnabledConfrontatClick' = 'chkOpt7Click'
  'TL_HandlerGetTickCountCheckClick' = 'chkOpt8Click'
  'TL_BlockResumeThreadClick' = 'chkOpt9Click'
}

foreach ($k in $repl.Keys) {
  $p = $p.Replace($k, $repl[$k])
}

$p = $p -replace '(?m)^(\s*)Form1(\s*:\s*TConfigWnd)', '${1}AppWnd${2}'

[System.IO.File]::WriteAllText($path, $p, (New-Object System.Text.UTF8Encoding $false))
