//
//  PastSearchesViewController.m
//  Readability
//
//  Created by Helen Weng on 3/8/14.
//  Copyright (c) 2014 JEHM. All rights reserved.
//

#import "PastSearchesViewController.h"
#import "Util.h"
#import <MessageUI/MessageUI.h>

@interface PastSearchTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *linkLabel;
@end

@implementation PastSearchTableViewCell
@end

@interface PastSearchesViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableDictionary *resultsDict;
@property (nonatomic, strong) NSArray *resultsKeys;


@end

@implementation PastSearchesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([MFMessageComposeViewController canSendText]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStylePlain target:self action:@selector(sendEmail)];
    }
    
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(YELLOW)];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(RED)};


    [self.tableView registerNib:[UINib nibWithNibName:@"PastSearchTableViewCell" bundle:nil] forCellReuseIdentifier:@"PastSearchTableViewCell"];

    
    // Return the number of rows in the section.
    self.resultsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"resultsDict"] mutableCopy];
    self.resultsKeys = [self.resultsDict allKeys];
    [self.tableView setBackgroundColor:UIColorFromRGB(BLUE)];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    self.resultsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"resultsDict"] mutableCopy];
    self.resultsKeys = [self.resultsDict allKeys];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PastSearchTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PastSearchTableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];

        
    }
    NSString *link = self.resultsKeys[indexPath.row];
    //cell.link = [NSString stringWithFormat:@"%@: %@", score, link];
    if ([cell isKindOfClass:[PastSearchTableViewCell class]]){
        ((PastSearchTableViewCell*)cell).scoreLabel.text = [self.resultsDict[link] stringValue];
        ((PastSearchTableViewCell*)cell).linkLabel.text = [Util omitHTMLPrefix:link];
    }
    
    if (indexPath.row % 3 == 0) {
        cell.backgroundColor = UIColorFromRGB(ORANGE);
    } else if (indexPath.row % 3 == 1) {
        cell.backgroundColor = UIColorFromRGB(BLUE);
    } else {
        cell.backgroundColor = UIColorFromRGB(RED);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.resultsKeys[indexPath.row]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.resultsDict removeObjectForKey:self.resultsKeys[indexPath.row]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.resultsDict forKey:@"resultsDict"];
        [defaults synchronize];
        self.resultsKeys = [self.resultsDict allKeys];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void) sendEmail {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if(mc){
        NSString *emailTitle = @"Your Readability List";
        
        
        NSString *messageBody = [self emailContents];
        
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }

    
    
}

-(NSString*) emailContents {
    NSMutableString *contents = [@"Your readability scores for the following links:\n\n" mutableCopy];
    for (NSString *link in self.resultsKeys) {
        [contents appendString: [NSString stringWithFormat:@"%@: %@\n", self.resultsDict[link], link]];
    }
    return contents;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
                                             
                                             

@end
