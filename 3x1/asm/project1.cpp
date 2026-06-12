#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define _CRT_SECURE_NO_WARNINGS
#include "stb_image.h"
#include "stb_image_write.h"
#include <iostream>

#define pixel_max(a) ((a) <= 255 ? (a) : 255)
#define pixel_min(a) ((a) >= 0 ? (a) : 0)

// Function to read an image in grayscale
unsigned char* readImage(const char* filename, int& width, int& height, int& channels) {
    unsigned char* image = stbi_load(filename, &width, &height, &channels, 1); // Load as grayscale
    if (!image) {
        std::cerr << "Failed to load image: " << stbi_failure_reason() << std::endl;
        return nullptr;
    }
    std::cout << "Image loaded successfully!" << std::endl;
    std::cout << "Width: " << width << ", Height: " << height << ", Channels: " << channels << std::endl;
    return image;
}

// Function to write an image to a PNG file
bool writeImage(const char* filename, unsigned char* image, int width, int height) {
    if (!image) {
        std::cerr << "Image data is null before writing!" << std::endl;
        return false;
    }
    if (width <= 0 || height <= 0) {
        std::cerr << "Invalid image dimensions: width = " << width << ", height = " << height << std::endl;
        return false;
    }
    // For grayscale images, stride is the same as the width
    int stride = width;
    if (stbi_write_png(filename, width, height, 1, image, stride) == 0) {
        std::cerr << "Failed to write the image to file: " << filename << std::endl;
        return false;
    }
    std::cout << "Image written successfully to: " << filename << std::endl;
    return true;
}

int main() {
    // Input and output file paths
    const char* inputFilename = "input_image1.png";
    const char* outputFilename1 = "output_image1.png";
    const char* outputFilename2 = "output_image2.png";

    // Image data variables
    int width, height, channels; // channels = 1 (grayscale)
    unsigned int number_of_pixels;

    // Read the input image
    unsigned char* image = readImage(inputFilename, width, height, channels);
    if (!image) 
        return -1; // Exit if the image failed to load

    // Allocate memory for the output image
    unsigned char* outputImage = new unsigned char[width * height];
    if (!outputImage) {
        std::cerr << "Failed to allocate memory for output image!" << std::endl;
        stbi_image_free(image);
        return -1;
    }

    // image is 1d array 
    // with length = width * height
    // pixels can be used as image[i] 
    // pixels can be updated as image[i] = 100, etc.
    // a pixel is defined as unsigned char
    // so a pixel can be 255 at max, and 0 at min.

    /* -------------------------------------------------------- QUESTION-1 -------------------------------------------------------- */
    
    /* Q-1 Inverse the colors of image. 
    Inverse -> pixel_color = 255 - pixel_color */

    number_of_pixels = width * height;
    __asm {
        MOV ECX, outputImage
        MOV EBX, image
        XOR ESI, ESI
        reverse:
            CMP ESI, number_of_pixels
            JAE end
  
            MOV AL, 255
            MOV DL, [EBX+ESI]
            SUB AL, DL
            MOV [ECX + ESI], AL
    
            INC ESI
            JMP reverse
         end:

    }

    // Write the modified image as output_image1.png
    if (!writeImage(outputFilename1, outputImage, width, height)) {
        stbi_image_free(image);
        return -1;
    }
    stbi_image_free(outputImage); // Clear the outputImage.

    /* -------------------------------------------------------- QUESTION-2 -------------------------------------------------------- */
    /* Histogram Equalization */

    outputImage = new unsigned char[width * height];
    if (!outputImage) {
        std::cerr << "Failed to allocate memory for output image!" << std::endl;
        stbi_image_free(image);
        return -1;
    }

    unsigned int* hist = (unsigned int*)malloc(sizeof(unsigned int) * 256);
    unsigned int* cdf = (unsigned int*)malloc(sizeof(unsigned int) * 256);

    // Check if memory allocation succeeded
    if (hist == NULL) {
        std::cerr << "Memory allocation for hist failed!" << std::endl;
        return -1;
    }
    if (cdf == NULL) {
        std::cerr << "Memory allocation for cdf failed!" << std::endl;
        free(hist);
        return -1;
    }

    // Both hist and cdf are initialized as zeros.
    for (int i = 0; i < 256; i++) {
        hist[i] = 0;
        cdf[i] = 0;
    }

    // You can define new variables here... As a hint some variables are already defined.
    unsigned int min_cdf, range;
    number_of_pixels = width * height;
    unsigned int mulcdf = 255;
    // Q-2 (a) - Compute the histogram of the input image.
    __asm {
        // Your assembly code here...
        MOV ECX, number_of_pixels
        MOV EBX, hist
        MOV ESI, image
    histogramloop:
        XOR EAX,EAX
        MOV AL, BYTE PTR [ESI]
        MOV EDI, EAX
        INC DWORD PTR [EBX + EDI * 4]
        INC ESI
        LOOP histogramloop
    }


   

    /* Q-2 (b) - Compute the Cumulative Distribution Function cdf
                    and save it to cdf array which is defined above. */

    // CDF Calculation (cdf[i] = cdf[i-1] + hist[i])
    unsigned int cdfToplam = 0;
    __asm {
        // Your assembly code here...
        MOV EDI, cdf
        MOV EBX, hist
        XOR EAX, EAX
        MOV ECX, 256
        XOR ESI,ESI
        cdfLoop:
            XOR EAX,EAX
            MOV EAX, DWORD PTR [EBX + ESI * 4] 
            ADD cdfToplam, EAX
            MOV EAX, cdfToplam
            MOV DWORD PTR [EDI + ESI * 4], EAX
            INC ESI
            LOOP cdfLoop
    }

    /* Q-2 (c) - Normalize the Cumulative Distribution Funtion 
                    that you have just calculated on the same cdf array. */

    // Normalized cdf[i] = ((cdf[i] - min_cdf) * 255) / range
    // range = (number_of_pixels - min_cdf)

    __asm {
        MOV ESI, cdf
        MOV ECX, 256
        XOR EBX,EBX
        mincdf:
            MOV EDX, DWORD PTR [ESI + EBX * 4]
            CMP EDX,0
            JNE found
            INC EBX
            LOOP mincdf
        found:
            MOV min_cdf, EDX
            MOV EAX, number_of_pixels
            SUB EAX, min_cdf
            MOV range, EAX
            XOR EDI,EDI
            MOV ECX, 256
         normalize:
            XOR EDX, EDX
            MOV EAX, DWORD PTR [ESI + EDI * 4]
            SUB EAX, min_cdf
            MUL mulcdf
            DIV range
            MOV DWORD PTR [ESI + EDI * 4], EAX
            INC EDI
            LOOP normalize

        
    }

    /* Q-2 (d) - Apply the histogram equalization on the image.
                    Write the new pixels to outputImage. */
	// Here you only need to get a pixel from image, say the value of pixel is 107
	// Then you need to find the corresponding cdf value for that pixel
	// The output for the pixel 107 will be cdf[107]
	// Do this for all the pixels in input image and write on output image.
    __asm {
            MOV ESI, image
            MOV EDI, outputImage
            MOV EBX, cdf
            MOV ECX, number_of_pixels
            apply_histogram_equalization :
            XOR EAX, EAX
                MOV AL, BYTE PTR [ESI]
                PUSH ESI
                MOV ESI, EAX
                MOV EAX, DWORD PTR [EBX + ESI * 4]
                POP ESI
                MOV [EDI], AL
                INC ESI
                INC EDI
                LOOP apply_histogram_equalization
        
    }

    // Write the modified image
    if (!writeImage(outputFilename2, outputImage, width, height)) {
        stbi_image_free(image); 
        return -1;
    }

    // Free the image memory
    stbi_image_free(image);
    stbi_image_free(outputImage);

    return 0;
}
