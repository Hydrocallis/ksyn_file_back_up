function Get-Version {
    # __init__.py ファイルを読み込み
    $initPyPath = Join-Path -Path (Get-Location) -ChildPath "__init__.py"
    $initPyContent = Get-Content $initPyPath -Raw

    # 正規表現を使用して "version" キーの値を取得
    $versionPattern = '"version"\s*:\s*\((\d+),\s*(\d+),\s*(\d+)\)'
    $versionMatch = [regex]::Match($initPyContent, $versionPattern)

    # マッチした場合は値を取得して表示
    if ($versionMatch.Success) {
        $majorVersion = $versionMatch.Groups[1].Value
        $minorVersion = $versionMatch.Groups[2].Value
        $patchVersion = $versionMatch.Groups[3].Value
        $version = "$majorVersion.$minorVersion.$patchVersion"

        # バージョン文字列を変更
        $version = $version.Replace(".", "_")
        $version = "v" + $version
        
        # バージョンを戻り値として返す
        return $version
    } else {
        Write-Host "バージョンが見つかりませんでした。"
    }
}

function Get-UniqueTagName($tagName) {
    # Check if tag name already exists
    $tagExists = git tag | Where-Object { $_ -eq $tagName }

    # If tag already exists, add "-beta" suffix to tag name
    if ($tagExists) {
        $newTagName = $tagName + "-beta"
        $betaExists = git tag | Where-Object { $_ -eq $newTagName }

        # If "-beta" version of tag already exists, use it
        if ($betaExists) {
            return $newTagName
        } else {
            return $newTagName
        }
    } else {
        return $tagName
    }
}


# 関数を呼び出して、戻り値を変数に格納する
$version = Get-Version

$tagName = $version

$newTagName = Get-UniqueTagName $tagName
Write-Output "New tag name: $newTagName"


git add .
git commit -m $newTagName
git tag $newTagName


# 現在のディレクトリのパッケージ名を取得
$currentPackage = Split-Path -Path (Get-Location) -Leaf

# 最新のコミットのタグを取得
$commitTag = git describe --tags 

# 変数を使用して git archive コマンドを実行
$currentDirectory = Get-Location
$parentDirectory = Split-Path -Path $currentDirectory -Parent
$output = "$parentDirectory\__release\$currentPackage" + "_$newTagName.zip"
git archive --prefix=$prefix --format=zip --output=$output $commitTag

Write-Host "出力成功しました。" + $output