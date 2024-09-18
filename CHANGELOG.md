## 0.0.1

- TODO: Describe initial release.

## 0.0.2

- Convert sample rate of audio buffer by user set in iOS. At now, we can set sample rate value for iOS platform.

## 0.0.3

- Fix bugs for `onCancel` failed and remove unnecessary files

## 1.0.0

- Support sound null safety

## 1.1.0

- Support Linux [#9](https://github.com/ysak-y/flutter_audio_capture/pull/9)

## 1.1.1

- General improvements and multithreading / start stop issues [#13](https://github.com/ysak-y/flutter_audio_capture/pull/13)

## 1.1.2

- Bump iOS minimum deplyment target to 13.6 from 12.4

## 1.1.3

- Fix using .defaultToSpeaker causes audio session initialization problems on iPhone [#14](https://github.com/ysak-y/flutter_audio_capture/issues/14)

## 1.1.4

- Disabled waiting for first data on iOS by default and timeout parameter added [#19](https://github.com/ysak-y/flutter_audio_capture/pull/19)
  - It is reported on [#16](https://github.com/ysak-y/flutter_audio_capture/issues/16)

## 1.1.5

- Update Kotlin language version to 1.9.10 (3ed3923ab799c2882940cffed989613298e6ecb1)
  - This version is to fix the bug that is reported in #20

## 1.1.6

- Change Kotlin language version to 1.7.10 (8f4cd5d26c92a79a089751bbdfd8dc030e3a6dff)
  - This version is to fix the bug that is reported in #20

## 1.1.7

- Use a setup and improve sampleRate transport #27

## 1.1.8

- Update gradle to 7.2 and target & compile SDK to API 34 #33