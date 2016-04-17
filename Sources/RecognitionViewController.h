#import <UIKit/UIKit.h>
#import "Client.h"



// Could be NSObject superclass or other class declared or UIViewController

@interface RecognitionViewController : UIViewController<ClientDelegate>


//Property to help getter and setter (Attribute1, attribute2) type propertyname;
//Property automatically creates getter and setter for you
//Property to store the textView Value 
@property (weak, nonatomic) IBOutlet UITextView *textView;





@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusIndicator;

@end
