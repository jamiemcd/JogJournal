//
//  JJCompletedJogsViewController.m
//  JogJournal
//
//  Created by Jamie McDaniel on 12/20/13.
//  Copyright (c) 2013 Curious Find. All rights reserved.
//

#import "JJCompletedJogsViewController.h"
#import "User+AdditionalMethods.h"
#import "Jog+AdditionalMethods.h"
#import "JJJogViewController.h"
#import "JJJogTableViewCell.h"
#import "UIFont+Custom.h"
#import "UIColor+Custom.h"

@interface JJCompletedJogsViewController ()

@property (nonatomic, strong) NSArray *jogs;

@end

// UITableViewCell reuse identifiers
static NSString *TableViewCellReuseIdentifer = @"TableViewCellReuseIdentifer";

@implementation JJCompletedJogsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = @"My Completed Jogs";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[JJJogTableViewCell class] forCellReuseIdentifier:TableViewCellReuseIdentifer];
}

- (void)setUser:(User *)user
{
    _user = user;
    NSMutableArray *jogs = [NSMutableArray array];
    for (Jog *jog in _user.jogs)
    {
        // Only completed jogs get added
        if (jog.endDate)
        {
            [jogs addObject:jog];
        }
    }
    // Now sort the array so that jogs that were completed more recent are listed first
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endDate" ascending:NO];
    self.jogs = [jogs sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.jogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellReuseIdentifer forIndexPath:indexPath];
    
    // Configure the cell...
    Jog *jog = self.jogs[indexPath.row];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    
    UIFont *font = [UIFont lightAppFontOfSize:16];
    UIColor *color = [UIColor blackColor];
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: color };
    NSAttributedString *attributedString1 = [[NSAttributedString alloc] initWithString:@"Distance:" attributes:attributes];
    NSAttributedString *attributedString3 = [[NSAttributedString alloc] initWithString:@"  Time:" attributes:attributes];
    
    font = [UIFont boldAppFontOfSize:16];
    color = [UIColor greenColor];
    attributes = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: color };
    NSAttributedString *attributedString2 = [[NSAttributedString alloc] initWithString:[jog distanceString] attributes:attributes];
    NSAttributedString *attributedString4 = [[NSAttributedString alloc] initWithString:[jog durationString] attributes:attributes];
    
    [mutableAttributedString appendAttributedString:attributedString1];
    [mutableAttributedString appendAttributedString:attributedString2];
    [mutableAttributedString appendAttributedString:attributedString3];
    [mutableAttributedString appendAttributedString:attributedString4];
    
    cell.textLabel.attributedText = mutableAttributedString;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Average Speed: %@", [jog averageSpeedString]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Jog *jog = self.jogs[indexPath.row];
    JJJogViewController *jogViewController = [[JJJogViewController alloc] init];
    jogViewController.jog = jog;
    [self.navigationController pushViewController:jogViewController animated:YES];
}

@end
