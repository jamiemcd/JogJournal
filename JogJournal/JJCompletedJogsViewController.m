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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewCellReuseIdentifer];
}

- (void)setUser:(User *)user
{
    _user = user;
    NSMutableArray *jogs = [NSMutableArray array];
    for (Jog *jog in _user.jogs)
    {
        if (jog.endDate)
        {
            [jogs addObject:jog];
        }
    }
    self.jogs = [jogs copy];
    
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [jog distanceString], [jog durationString]];
    
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
