#import <UIKit/UIKit.h>

#import "AppDelegate.h"



// we always start with main, which is a function

int main(int argc, char *argv[])
{
	//statements since C is not object oriented
    //creates a poor of memory
    @autoreleasepool {
        // has to return an int
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
