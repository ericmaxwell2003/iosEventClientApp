
#import "EventTableViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"
#import "EventService.h"
#import "EventDto.h"
#import "EventTableViewCell.h"
#import "MMProgressHUD.h"

static NSString *initialPage = @"";

@interface EventTableViewController ()

@property (nonatomic, strong) NSMutableArray *eventList;
@property (nonatomic, strong) NSString *lastSyncToken;

@end

@implementation EventTableViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventList = [NSMutableArray array];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.title = @"Events";
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newEventsLoaded:) name:EVENTS_CALL_COMPLETED_WITH_RESULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorLoadingEvents:) name:EVENTS_CALL_FAILED_WITH_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    // refresh new data when pull the table list
    [self.tableView addPullToRefreshWithActionHandler:^{
//        [weakSelf.eventList removeAllObjects]; // remove all data
        [weakSelf.tableView reloadData]; // before load new content, clear the existing table list
        [weakSelf loadFromServer]; // load new data
        [weakSelf.tableView.pullToRefreshView stopAnimating]; // clear the animation
        
    }];
    
    // load initial set from server on start.
    [self loadFromServer];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - notification events
- (void)newEventsLoaded:(NSNotification*)notification
{
    NSDictionary *results = notification.object;

    self.lastSyncToken = [results objectForKey:@"syncToken"];
    NSArray *events = [results objectForKey:@"events"];
    // if no more result
    if ([events count] == 0) {
        return;
    }
    
    // need to reverse so the latest new ones appear first in the list
    for (id obj in [events reverseObjectEnumerator]) {
        [self.eventList insertObject:obj atIndex:0];
    }

    [self.tableView reloadData];

    
    // clear the pull to refresh & infinite scroll, this 2 lines very important
    [self.tableView.pullToRefreshView stopAnimating];
    [MMProgressHUD dismissWithSuccess:@"" title:@"" afterDelay:0.2];
}

- (void)errorLoadingEvents:(NSNotification*)notification
{
    NSError *error = notification.object;
    NSLog(@"error %@", error);
    [MMProgressHUD dismissWithError:@"" title:@"Unable to Fetch Events" afterDelay:1.0];
}

/**
 *  This is helpful for the scenario where the user did not have a data connection, and loadded no posts.
 *  Then, backgrounded the app and came back in.  In this case, it's nice to try to load posts again for them
 *  Without handling this event, they come into an empty tableView.
 */
- (void)handleDidBecomeActive:(NSNotification *)notification
{
    // We only want to reload the table if there were no posts.  It's annoying to reaload every time
    // they bounce between this and another app otherwise.
    if(self.eventList.count == 0) {
        [self loadFromServer];
    }
}


#pragma mark - UITableViewDataSource and Helpers
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    EventDto *event = [self.eventList objectAtIndex:[indexPath row]];
    cell.summary.text = event.summary;
    cell.detail.text = event.details;
    return cell;
}

- (void)loadFromServer
{
    // if the list is currently empty, we want to show the global loading
    // otherwise we'll not and just let SVPullToRefresh indicators display.
    if(self.eventList.count == 0) {
        [MMProgressHUD showWithTitle:@"Loading..."];
    }
    
    EventService *service = [EventService sharedInstance];
    [service loadEventsFromServerUsingSyncToken:self.lastSyncToken];
}



@end
