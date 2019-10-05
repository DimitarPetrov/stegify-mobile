# stegify_mobile

Stegify is a multi-platform mobile application written with Flutter currently in active development.
It provides functionality same as [stegify](https://github.com/DimitarPetrov/stegify), but as a mobile application for
android and ios.

In fact the underlying implementation of the [steganography](https://en.wikipedia.org/wiki/steganography) encoding/decoding is [stegify](https://github.com/DimitarPetrov/stegify)
Go implementation used as flutter plugin in this project which can be found here: [stegify-flutter-plugin](https://github.com/DimitarPetrov/stegify-flutter-plugin).

## Demonstration

| Carrier                                | Data                                | Result                                               |
| ---------------------------------------| ------------------------------------|------------------------------------------------------|
| ![Original File](https://github.com/DimitarPetrov/stegify/blob/master/examples/street.jpeg) | ![Encoded File](https://github.com/DimitarPetrov/stegify/blob/master/examples/lake.jpeg) | ![Encoded File](https://github.com/DimitarPetrov/stegify/blob/master/examples/test_decode.jpeg) |

The `Result` file contains the `Data` file hidden in it. And as you can see it is fully transparent.
