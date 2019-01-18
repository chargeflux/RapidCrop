# RapidCrop

**RapidCrop** is a Swift app that allows the user to rapidly crop an image by dragging or clicking twice for a starting and ending point for each new rectangle. Multiple cropping regions can be created on a single image and saved.

## Compilation

1) Launch `RapidCrop.xcodeproj`
2) Build

## Usage

1) Drag an image (.jpg, .png, .pdf, etc.) to the window
2) Click and drag to draw cropping rectangles, outlined in black. Each cropping region is independent of each other and can overlap
3) Press `CMD` and click on the image at 2 points to draw a cropping rectangle without having to drag
4) Press `CMD` + `S` to save all cropping rectangles to `~/Downloads/Output` where it will be saved in a directory with the image file's name. Rectangles are saved in the order of which they are created
5) Press `Esc` to remove the last cropping rectangle created  

## TODO

1) Allow for custom output directory
2) Dim the input image and show a non-dimmed version of the image in cropping regions
3) Display the dimensions of the cropping region being created when dragging

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](./LICENSE.txt)