# WSLでFlutter開発する方法メモ

もしWindowsでの開発を始めたいときはこの情報を参考にしてください。

## Summary
- flutterのバージョン管理にはfvmを使う
- WSLを使ってWindowsホスト側のEmulatorを利用して開発をする方法は https://dev.to/abdullahyasir/flutter-development-setup-for-wsl2-windows-android-studio-complete-guide-4493
- Android Studioをインストールしてショートカット作成を省略すると C:\Program Files\Android\Android Studio\bin からstudioのアプリを起動する必要がある

## 0. 準備
- fvmのインストール
- java 17のインストール

## 1. ~/.bashrc設定

```
# --- Android SDK + Flutter Development (WSL2 with Windows Android Studio)

# User bin (for wrappers like adb)
export PATH="$HOME/bin:$PATH"

# Android SDK (Windows)
export ANDROID_HOME=/mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# Add Android tools
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"

# Flutter (FVM)
export PATH="$HOME/fvm/default/bin:$PATH"
export PUB_CACHE="$HOME/.pub-cache"
export PATH="$PATH:$PUB_CACHE/bin"
```

## 2. Wrapper Scriptの設定

```
mkdir -p ~/bin

cat > ~/bin/adb << 'EOF'
#!/bin/bash
exec /mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk/platform-tools/adb.exe "$@"
EOF

cat > ~/bin/aapt << 'EOF'
#!/bin/bash
exec /mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk/build-tools/36.1.0/aapt.exe "$@"
EOF

cat > ~/bin/aapt2 << 'EOF'
#!/bin/bash
exec /mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk/build-tools/36.1.0/aapt2.exe "$@"
EOF

cat > ~/bin/zipalign << 'EOF'
#!/bin/bash
exec /mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk/build-tools/36.1.0/zipalign.exe "$@"
EOF

chmod +x ~/bin/adb ~/bin/aapt ~/bin/aapt2 ~/bin/zipalign
```

## 3. ビルドツールのコピー

```
cd /mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk/build-tools/36.1.0/
cmd.exe /c "copy aapt.exe aapt"
cmd.exe /c "copy aapt2.exe aapt2"
cmd.exe /c "copy zipalign.exe zipalign"
cmd.exe /c "copy aidl.exe aidl"
```

## 4. ADBのシンボリックリンク作成

```
ln -s ~/bin/adb /mnt/c/Users/<your_windows_username>/AppData/Local/Android/Sdk/platform-tools/adb
```

## 設定できているかの確認

### flutter doctor

```
flutter doctor
```

`[✓] Connected device` となっていればok

#### check `android/local.properties`

flutter doctor実行後は以下のようになっているはず

```
sdk.dir=/mnt/c/Users/yuyay/AppData/Local/Android/Sdk
```

WindowsのPATHフォーマットを利用するのであれば以下

```
sdk.dir=C:\\Users\\<your_windows_username>\\AppData\\Local\\Android\\Sdk
```

### flutter devices

## もしもの回避策

ADBのエラー

```
adb kill-server
adb start-server
```

Gradleビルドのエラー

```
flutter clean
rm -rf android/.gradle
```
