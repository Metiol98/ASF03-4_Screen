$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$managementPath = Join-Path $root '泵管管理.tft'
$alertPath = Join-Path $root '泵管提醒弹窗.tft'
$mainPath = Join-Path $root '工作界面.tft'

function Load-Xml($path) {
    $document = [System.Xml.XmlDocument]::new()
    $document.PreserveWhitespace = $false
    $document.Load($path)
    return $document
}

function Save-Xml($document, $path) {
    $settings = [System.Xml.XmlWriterSettings]::new()
    $settings.Encoding = [System.Text.UTF8Encoding]::new($false)
    $settings.Indent = $false
    $writer = [System.Xml.XmlWriter]::Create($path, $settings)
    $document.Save($writer)
    $writer.Dispose()
}

# Match the project's black text while retaining each pump's green/alert status color.
$management = Load-Xml $managementPath
$statusIds = @('15','23','31','39')
foreach ($item in $management.SelectNodes('/DrawPage/item[@type="text_display"]')) {
    if ($item.GetAttribute('id') -notin $statusIds) {
        $item.SetAttribute('fore_color', '0;0;0')
    }
}
foreach ($id in @('11','12','13','14','15','19','20','21','22','23','27','28','29','30','31','35','36','37','38','39')) {
    $management.SelectSingleNode("/DrawPage/item[@id='$id']").SetAttribute('text', '')
}
Save-Xml $management $managementPath

# Keep replacement actions as delayed long-press events, not reset-style buttons.
$management = Load-Xml $managementPath
foreach ($id in @('16','24','32','40')) {
    $button = $management.SelectSingleNode("/DrawPage/item[@id='$id']")
    $button.SetAttribute('button_style', '5')
    $button.SetAttribute('longpress_delay', '3000')
}

# Widen both hour columns and shift later columns to retain clear spacing.
$columns = @{
    '4'=@{x=145;w=165}; '11'=@{x=145;w=165}; '19'=@{x=145;w=165}; '27'=@{x=145;w=165}; '35'=@{x=145;w=165}
    '5'=@{x=320;w=165}; '12'=@{x=320;w=165}; '20'=@{x=320;w=165}; '28'=@{x=320;w=165}; '36'=@{x=320;w=165}
    '6'=@{x=495;w=150}; '13'=@{x=495;w=150}; '21'=@{x=495;w=150}; '29'=@{x=495;w=150}; '37'=@{x=495;w=150}
    '7'=@{x=655;w=150}; '14'=@{x=655;w=150}; '22'=@{x=655;w=150}; '30'=@{x=655;w=150}; '38'=@{x=655;w=150}
    '8'=@{x=815;w=120}; '15'=@{x=815;w=120}; '23'=@{x=815;w=120}; '31'=@{x=815;w=120}; '39'=@{x=815;w=120}
    '9'=@{x=945;w=220}; '16'=@{x=945;w=220}; '17'=@{x=945;w=220}; '24'=@{x=945;w=220}; '25'=@{x=945;w=220}
    '32'=@{x=945;w=220}; '33'=@{x=945;w=220}; '40'=@{x=945;w=220}; '41'=@{x=945;w=220}
}
foreach ($id in $columns.Keys) {
    $item = $management.SelectSingleNode("/DrawPage/item[@id='$id']")
    $item.SetAttribute('xOffset', [string]$columns[$id].x)
    $item.SetAttribute('width', [string]$columns[$id].w)
}
Save-Xml $management $managementPath

# Keep the four runtime-bound alert rows empty until STM32 sends active pump reasons.
$alert = Load-Xml $alertPath
foreach ($id in @('3','4','5','6')) {
    $alert.SelectSingleNode("/DrawPage/item[@id='$id']").SetAttribute('text', '')
}
foreach ($item in $alert.SelectNodes('/DrawPage/item[@type="text_display"]')) {
    $item.SetAttribute('fore_color', '0;0;0')
}
Save-Xml $alert $alertPath

# Draw hollow red warning triangles with white centers and pump numbers.
for ($pump = 1; $pump -le 4; $pump++) {
    $bitmap = [System.Drawing.Bitmap]::new(40, 44, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $triangle = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $triangle.AddBezier(20, 2, 22, 2, 23, 3, 24, 5)
    $triangle.AddLine(24, 5, 37, 37)
    $triangle.AddBezier(37, 37, 39, 41, 36, 43, 32, 43)
    $triangle.AddLine(32, 43, 8, 43)
    $triangle.AddBezier(8, 43, 4, 43, 1, 41, 3, 37)
    $triangle.AddLine(3, 37, 16, 5)
    $triangle.AddBezier(16, 5, 17, 3, 18, 2, 20, 2)
    $triangle.CloseFigure()
    $red = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(235, 48, 48), 3.2)
    $red.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $red.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $red.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawPath($red, $triangle)
    $font = [System.Drawing.Font]::new('Arial', 19, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $graphics.DrawString([string]$pump, $font, $brush, [System.Drawing.RectangleF]::new(9, 13, 22, 22), $format)
    $bitmap.Save((Join-Path $root "images\pump_tube_$pump.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose(); $bitmap.Dispose(); $red.Dispose(); $font.Dispose(); $format.Dispose(); $brush.Dispose(); $triangle.Dispose()
}

# Generate an editable, self-contained SVG from the current LCD control positions.
$main = Load-Xml $mainPath
$backgroundPath = Join-Path $root 'images\pump_tube_manage_bg.png'
$background = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($backgroundPath))
$offSwitch = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Join-Path $root 'images\资源 7@4x-8.png')))
$onSwitch = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Join-Path $root 'images\资源 9@4x-8.png')))
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1280" height="720" viewBox="0 0 1280 720">')
[void]$sb.AppendLine("<image x='0' y='0' width='1280' height='720' xlink:href='data:image/png;base64,$background'/>")
[void]$sb.AppendLine('<g font-family="Microsoft YaHei, Noto Sans CJK SC, sans-serif" fill="#000000">')
[void]$sb.AppendLine('<rect x="24" y="88" width="1232" height="584" rx="12" fill="#f4fafd"/>')

$management = Load-Xml $managementPath
foreach ($item in $management.SelectNodes('/DrawPage/item')) {
    $id = $item.GetAttribute('id')
    $type = $item.GetAttribute('type')
    $x = [int]$item.GetAttribute('xOffset'); $y = [int]$item.GetAttribute('yOffset')
    $w = [int]$item.GetAttribute('width'); $h = [int]$item.GetAttribute('height')
    if ($id -eq '1') {
        [void]$sb.AppendLine("<image x='$x' y='$y' width='$w' height='$h' xlink:href='data:image/png;base64,$offSwitch'/>")
    } elseif ($type -eq 'text_display') {
        $label = [System.Security.SecurityElement]::Escape($item.GetAttribute('text'))
        if ($label) {
            $fontSize = if ($id -eq '44') { 24 } else { 32 }
            $anchor = if ($item.GetAttribute('text_align') -eq '0') { 'start' } else { 'middle' }
            $tx = if ($anchor -eq 'start') { $x } else { $x + [int]($w / 2) }
            $ty = $y + [int]($h / 2) + [int]($fontSize / 3)
            $color = if ($statusIds -contains $id) { '#1f9a6b' } else { '#000000' }
            [void]$sb.AppendLine("<text x='$tx' y='$ty' text-anchor='$anchor' font-size='$fontSize' fill='$color'>$label</text>")
        }
        if ($id -in @('12','14','20','22','28','30','36','38')) {
            [void]$sb.AppendLine("<rect x='$x' y='$y' width='$w' height='$h' fill='none' stroke='#35a9ed' stroke-width='1'/>")
        }
    } elseif ($type -eq 'button' -and $id -in @('16','24','32','40')) {
        [void]$sb.AppendLine("<rect x='$x' y='$y' width='$w' height='$h' rx='4' fill='#b5e3f7'/>")
        $ty = $y + [int]($h / 2) + 11
        [void]$sb.AppendLine("<text x='$($x + [int]($w/2))' y='$ty' text-anchor='middle' font-size='32' fill='#000000'>更换泵管</text>")
    }
}
[void]$sb.AppendLine('</g></svg>')
[System.IO.File]::WriteAllText((Join-Path $root '泵管管理_Figma.svg'), $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
