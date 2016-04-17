#import "RecognitionViewController.h"
#import "AppDelegate.h"










// 1st

// Parameters of Clients
static NSString* MyApplicationID = @"iamgenius";
static NSString* MyPassword = @"Q42X4EG2Bbgpy37ZzV2j0qSO";


@implementation RecognitionViewController
// Import Property
@synthesize textView;
@synthesize statusLabel;
@synthesize statusIndicator;







// Do Nothing

- (void)didReceiveMemoryWarning // Release any cached data, images, etc that aren't in use.

{
    [super didReceiveMemoryWarning];
}


// View lifecycle
// viewDidLoad better than init to put starter code --> prepared for segue + instantiation + outlet all set
#pragma mark - View lifecycle


- (void)viewDidLoad // Usually update UI since outlet all set
{
    [super viewDidLoad];
}


//2nd

// Put "remember what is going on" + cleanup code

- (void)viewDidUnload
{
	[self setTextView:nil];
	[self setStatusLabel:nil];
	[self setStatusIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view. --> Clean up code
    // e.g. self.myOutlet = nil;
    // Get rid of big image that is expensive
}









//3rd

// viewWillAppear viewWillDisappear are called each time controller goes on and off screen

// Everytime your view appears on the screen e.g. split view master, protrait orientation
// Use this to optimize performance by waiting until this method is called to kick off an expensive operation
// Show Status Label + Status Indicator
- (void)viewWillAppear:(BOOL)animated
{
	textView.hidden = YES;
	statusLabel.hidden = NO;
	statusIndicator. hidden = NO;
    [super viewWillAppear:animated];
}






//4th

// Load and Upload Image
// -InstanceVariable(ReturnType)MethodName:(ParameterType)ParamenterName
// Sent to you when you did appear on screen 

- (void)viewDidAppear:(BOOL)animated
{
	statusLabel.text = @"Pre-processing Image";
	
    
    
    
    
    // NO Memory Allocation to create object
    // AppDelegate = Image to Process
	UIImage* image = [(AppDelegate*)[[UIApplication sharedApplication] delegate] imageToProcess];
    
    //Memory Allocation
	//ClassName *Object = [[ClassName alloc]init];
    //Allocate memory on an object so that the object for method to call on
	Client *client = [[Client alloc] initWithApplicationID:MyApplicationID password:MyPassword];
    
    
    
    
    
	[client setDelegate:self];
	
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"installationID"] == nil) {
        
        // deviceID = bundle identifier
		NSString* deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
		// installationID =
		NSLog(@"First run: obtaining installation ID..");
		NSString* installationID = [client activateNewInstallation:deviceID];
		NSLog(@"Done. Installation ID is \"%@\"", installationID);
		
		[[NSUserDefaults standardUserDefaults] setValue:installationID forKey:@"installationID"];
	}
	
	NSString* installationID = [[NSUserDefaults standardUserDefaults] stringForKey:@"installationID"];
	
    
    
    
    
    
    
    
    // applicationID =
	client.applicationID = [client.applicationID stringByAppendingString:installationID];

    
    
    //Create Object + Allocate memory on the object for method to call on
    //Call alloc method on Class to create object AND THEN call init method on the retunring object
	ProcessingParams* params = [[ProcessingParams alloc] init];
	
    
    
    // Run processImage method on Object Client 
	[client processImage:image withParams:params];
	
    
    
    
	statusLabel.text = @"Running Algorithm";
	
    [super viewDidAppear:animated];
}






- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}









// 5th

// Processing Image + Download Result

#pragma mark - ClientDelegate implementation

- (void)clientDidFinishUpload:(Client *)sender
{
	statusLabel.text = @"Converting into text";
}

- (void)clientDidFinishProcessing:(Client *)sender
{
	statusLabel.text = @"Resizing text";
}


//Display Results
//Convert given data into unicode characters

- (void)client:(Client *)sender didFinishDownloadData:(NSData *)downloadedData
{
	statusLabel.hidden = YES;
	statusIndicator.hidden = YES;
	
	textView.hidden = NO;
	
	NSString* result = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
	
	textView.text = result;
    
    NSInteger lengthThreshold = 50;
    if( [ textView.text length ] > lengthThreshold ) {
        NSInteger newSize = 6; //calculate new size based on length
        
        [ textView setFont: [ UIFont systemFontOfSize: newSize ]];
    }
}





// MESSAGE PASSING
// EXAMPLE like RayWenderlich
// Method Client
// Allocate Memory on Object alert
// Calling METHOD show on OBJECT alert
- (void)client:(Client *)sender didFailedWithError:(NSError *)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:nil, nil];
	
    
    
	[alert show];
	
	statusLabel.text = [error localizedDescription];
	statusIndicator.hidden = YES;
}

@end
