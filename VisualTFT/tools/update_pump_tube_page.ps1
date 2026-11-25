$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$pagePath = Join-Path $root '泵管管理.tft'
$backgroundPath = Join-Path $root 'images\pump_tube_manage_bg.png'
$figmaPath = Join-Path $root '泵管管理_Figma.svg'

# Reuse the established screen artwork as a branded frame and keep the data area clear.
$source = [System.Drawing.Image]::FromFile((Join-Path $root 'images\ASF-03X4加液界面2-02.png'))
$bitmap = [System.Drawing.Bitmap]::new(1280, 720)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawImage($source, 0, 0, 1280, 720)
$panelBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(244, 250, 253))
$path = [System.Drawing.Drawing2D.GraphicsPath]::new()
$path.AddArc(24, 54, 24, 24, 180, 90)
$path.AddArc(1232, 54, 24, 24, 270, 90)
$path.AddArc(1232, 672, 24, 24, 0, 90)
$path.AddArc(24, 672, 24, 24, 90, 90)
$path.CloseFigure()
$graphics.FillPath($panelBrush, $path)
$bitmap.Save($backgroundPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose(); $source.Dispose(); $bitmap.Dispose(); $panelBrush.Dispose(); $path.Dispose()

[xml]$xml = [System.IO.File]::ReadAllText($pagePath, [System.Text.Encoding]::UTF8)
$items = @{}
foreach ($item in $xml.DrawPage.item) { $items[$item.GetAttribute('id')] = $item }

# Brand header and column geometry fit the full 32 px font, including unit suffixes.
$layout = @{
    '2'=@{x=780;y=27;w=180;h=62;font=12}
    '3'=@{x=40;y=133;w=105;h=44;font=12}
    '4'=@{x=150;y=133;w=180;h=44;font=12}
    '5'=@{x=335;y=133;w=180;h=44;font=12}
    '6'=@{x=520;y=133;w=170;h=44;font=12}
    '7'=@{x=695;y=133;w=170;h=44;font=12}
    '8'=@{x=870;y=133;w=125;h=44;font=12}
    '9'=@{x=1010;y=133;w=220;h=44;font=12}
    '10'=@{x=40;w=105;font=12}; '11'=@{x=150;w=180;font=12}; '12'=@{x=335;w=180;font=12}; '13'=@{x=520;w=170;font=12}; '14'=@{x=695;w=170;font=12}; '15'=@{x=870;w=125;font=12}; '16'=@{x=1010;w=220;h=72;font=12}
    '18'=@{x=40;w=105;font=12}; '19'=@{x=150;w=180;font=12}; '20'=@{x=335;w=180;font=12}; '21'=@{x=520;w=170;font=12}; '22'=@{x=695;w=170;font=12}; '23'=@{x=870;w=125;font=12}; '24'=@{x=1010;w=220;h=72;font=12}
    '26'=@{x=40;w=105;font=12}; '27'=@{x=150;w=180;font=12}; '28'=@{x=335;w=180;font=12}; '29'=@{x=520;w=170;font=12}; '30'=@{x=695;w=170;font=12}; '31'=@{x=870;w=125;font=12}; '32'=@{x=1010;w=220;h=72;font=12}
    '34'=@{x=40;w=105;font=12}; '35'=@{x=150;w=180;font=12}; '36'=@{x=335;w=180;font=12}; '37'=@{x=520;w=170;font=12}; '38'=@{x=695;w=170;font=12}; '39'=@{x=870;w=125;font=12}; '40'=@{x=1010;w=220;h=72;font=12}
    '17'=@{x=1010;w=220;h=72;font=12}; '25'=@{x=1010;w=220;h=72;font=12}; '33'=@{x=1010;w=220;h=72;font=12}; '41'=@{x=1010;w=220;h=72;font=12}
    '42'=@{x=1040;y=610;w=180;h=62;font=12}; '43'=@{x=1040;y=610;w=180;h=62;font=12}; '44'=@{x=40;y=610;w=850;h=46;font=10}
}
foreach ($id in $layout.Keys) {
    $item = $items[$id]
    $entry = $layout[$id]
    foreach ($property in @('x','y','w','h','font')) {
        if ($entry.ContainsKey($property)) {
            $attribute = switch ($property) { 'x' {'xOffset'} 'y' {'yOffset'} 'w' {'width'} 'h' {'height'} 'font' {'font'} }
            $item.SetAttribute($attribute, [string]$entry[$property])
        }
    }
}

# Use VisualTFT's delay action style and keep the three-second long-press threshold.
foreach ($id in @('16','24','32','40')) {
    $items[$id].SetAttribute('button_style', '2')
    $items[$id].SetAttribute('longpress_delay', '3000')
}

# Give unit-bearing labels enough room and match the configured screen font.
$items['4'].SetAttribute('text', '运行时间 (h)')
$items['5'].SetAttribute('text', '时间限值 (h)')
$items['4'].SetAttribute('text_len_max', '32')
$items['5'].SetAttribute('text_len_max', '32')
$items['1'].SetAttribute('button_style', '1')
$items['1'].SetAttribute('init_state', '0')
$items['1'].SetAttribute('url_up', 'images\资源 7@4x-8.png')
$items['1'].SetAttribute('url_down', 'images\资源 9@4x-8.png')
[System.IO.File]::WriteAllText($pagePath, $xml.OuterXml, [System.Text.UTF8Encoding]::new($false))

# Export an editable vector layout for Figma, embedding the exact LCD background image.
$backgroundData = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($backgroundPath))
$svg = @'
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1280" height="720" viewBox="0 0 1280 720">
  <image x="0" y="0" width="1280" height="720" xlink:href="data:image/png;base64,__BACKGROUND__"/>
  <g font-family="Microsoft YaHei, Noto Sans CJK SC, sans-serif" text-anchor="middle" fill="#1f4762">
    <text x="870" y="68" fill="#ffffff" font-size="32">泵管监测</text>
    <image x="972" y="27" width="250" height="62" xlink:href="data:image/png;base64,__OFF__"/>
    <g fill="#335d76" font-size="32">
      <text x="92" y="165">泵号</text><text x="240" y="165">运行时间 (h)</text><text x="425" y="165">时间限值 (h)</text><text x="605" y="165">累计圈数</text><text x="780" y="165">圈数限值</text><text x="932" y="165">状态</text><text x="1120" y="165">更换泵管</text>
    </g>
    <g font-size="32">
      <rect x="40" y="189" width="1190" height="72" fill="#f5fbfe"/><rect x="40" y="279" width="1190" height="72" fill="#f5fbfe"/><rect x="40" y="369" width="1190" height="72" fill="#f5fbfe"/><rect x="40" y="459" width="1190" height="72" fill="#f5fbfe"/>
      <g fill="#1f4762"><text x="92" y="235">1号泵</text><text x="240" y="235">0.0</text><text x="425" y="235">未设置</text><text x="605" y="235">0</text><text x="780" y="235">未设置</text><text x="932" y="235" fill="#1f9a6b">正常</text>
      <text x="92" y="325">2号泵</text><text x="240" y="325">0.0</text><text x="425" y="325">未设置</text><text x="605" y="325">0</text><text x="780" y="325">未设置</text><text x="932" y="325" fill="#1f9a6b">正常</text>
      <text x="92" y="415">3号泵</text><text x="240" y="415">0.0</text><text x="425" y="415">未设置</text><text x="605" y="415">0</text><text x="780" y="415">未设置</text><text x="932" y="415" fill="#1f9a6b">正常</text>
      <text x="92" y="505">4号泵</text><text x="240" y="505">0.0</text><text x="425" y="505">未设置</text><text x="605" y="505">0</text><text x="780" y="505">未设置</text><text x="932" y="505" fill="#1f9a6b">正常</text></g>
      <g fill="#b5e3f7"><rect x="1010" y="189" width="220" height="72" rx="4"/><rect x="1010" y="279" width="220" height="72" rx="4"/><rect x="1010" y="369" width="220" height="72" rx="4"/><rect x="1010" y="459" width="220" height="72" rx="4"/></g>
      <g><text x="1120" y="235">更换泵管</text><text x="1120" y="325">更换泵管</text><text x="1120" y="415">更换泵管</text><text x="1120" y="505">更换泵管</text></g>
      <text x="1120" y="657">返回</text>
    </g>
    <text x="465" y="643" text-anchor="start" font-size="24" fill="#4e7084">时间和圈数任一达到限值即提醒</text>
  </g>
</svg>
'@
$offData = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Join-Path $root 'images\资源 7@4x-8.png')))
$svg = $svg.Replace('__BACKGROUND__', $backgroundData).Replace('__OFF__', $offData)
[System.IO.File]::WriteAllText($figmaPath, $svg, [System.Text.UTF8Encoding]::new($false))
