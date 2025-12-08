# APK Size Optimization Guide for SehatApp

## Current Size: ~120MB

## 🎯 Optimization Strategies

### 1. **Enable App Bundle (AAB) Instead of APK** ⭐ Most Effective
**Savings: 40-60%**

Instead of building APK, build Android App Bundle:
```bash
flutter build appbundle --release
```

**Why?**
- Google Play automatically generates optimized APKs for each device
- Only downloads necessary resources (screen density, architecture)
- Typical reduction: 120MB → 50-70MB

---

### 2. **Split APKs by ABI** ⭐ Effective for APK
**Savings: 30-40%**

Build separate APKs for different architectures:
```bash
flutter build apk --split-per-abi --release
```

This creates 3 APKs:
- `app-armeabi-v7a-release.apk` (~40MB) - 32-bit ARM
- `app-arm64-v8a-release.apk` (~45MB) - 64-bit ARM (most modern devices)
- `app-x86_64-release.apk` (~50MB) - Emulators/Intel devices

**Upload only `arm64-v8a` for most users.**

---

### 3. **Optimize Assets**
**Savings: 10-20MB**

#### Check Asset Sizes:
```bash
# List large files
find assets -type f -size +100k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
```

#### Optimize Images:
- Use WebP format instead of PNG/JPG
- Compress images: https://tinypng.com or https://squoosh.app
- Remove unused images

#### Optimize Lottie Animations:
- Reduce complexity
- Remove unused animations

---

### 4. **Remove Unused Dependencies**

Check for unused packages:
```bash
flutter pub deps --no-dev | grep "^[├└]"
```

**Potentially Large Dependencies:**
- `google_fonts` (can be 5-10MB) - Consider using only specific fonts
- `lottie` - Remove if not heavily used
- `flutter_webrtc` - Large but necessary for calls

---

### 5. **Optimize Google Fonts**

Instead of loading all fonts, specify only what you need:

```yaml
# pubspec.yaml
dependencies:
  # Remove: google_fonts: ^6.3.3
  
# Download specific fonts and add to assets:
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Bold.ttf
        weight: 700
```

**Savings: 5-8MB**

---

### 6. **Enable Code Shrinking & Obfuscation**

Update `android/app/build.gradle`:

```gradle
android {
    buildTypes {
        release {
            // Enable code shrinking
            minifyEnabled true
            shrinkResources true
            
            // Obfuscate code
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Savings: 10-15MB**

---

### 7. **Optimize WebRTC**

WebRTC is large. If you're not using all features:

```yaml
# Consider using a lighter alternative or custom build
# Current: flutter_webrtc: ^1.2.1
```

**Savings: 5-10MB** (if you can reduce features)

---

### 8. **Remove Debug Symbols**

Already done in release mode, but verify:
```bash
flutter build apk --release --no-tree-shake-icons
```

---

### 9. **Compress Native Libraries**

In `android/app/build.gradle`:

```gradle
android {
    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}
```

**Savings: 5-10MB**

---

## 📊 Expected Results

| Method | Size Reduction | Final Size |
|--------|---------------|------------|
| **App Bundle (AAB)** | 40-60% | **50-70MB** |
| **Split APKs** | 30-40% | **70-85MB** |
| **Asset Optimization** | 10-20MB | **100-110MB** |
| **Remove Google Fonts** | 5-8MB | **112-115MB** |
| **Code Shrinking** | 10-15MB | **105-110MB** |
| **All Combined** | 50-70% | **35-60MB** |

---

## 🚀 Quick Win Commands

### For Production (Recommended):
```bash
# Build App Bundle (best for Google Play)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Or build split APKs
flutter build apk --split-per-abi --release --obfuscate --split-debug-info=build/debug-info
```

### For Testing:
```bash
# Build single APK with analysis
flutter build apk --release --target-platform android-arm64 --analyze-size
```

---

## 📝 Implementation Checklist

- [ ] Switch to App Bundle (AAB) for Google Play
- [ ] Enable code shrinking in build.gradle
- [ ] Optimize/compress images in assets/
- [ ] Remove unused Lottie animations
- [ ] Replace google_fonts with local fonts
- [ ] Enable resource shrinking
- [ ] Build split APKs for distribution
- [ ] Test on real devices

---

## 🔍 Analyze Current Size

```bash
# Analyze APK size breakdown
flutter build apk --release --target-platform android-arm64 --analyze-size

# This will show you:
# - Which packages are largest
# - Asset sizes
# - Native library sizes
```

---

## ⚠️ Important Notes

1. **App Bundle is the future** - Google Play requires AAB for new apps
2. **Split APKs** - Users only download what they need
3. **Test thoroughly** - After optimization, test all features
4. **Backup first** - Commit your changes before major optimizations

---

## 🎯 Priority Actions (Do These First)

1. **Build App Bundle** instead of APK → Instant 40-50% reduction
2. **Enable code shrinking** → 10-15MB reduction
3. **Optimize assets** → 10-20MB reduction
4. **Use split APKs** if not using AAB → 30-40% reduction

**Expected final size: 35-60MB** (from 120MB)
