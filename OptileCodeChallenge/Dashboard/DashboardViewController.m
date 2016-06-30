//
//  DashboardViewController.m
//  OptileCodeChallenge
//
//  Created by Deepak on 29/06/16.
//  Copyright © 2016 Bayatree Infocom Private Limited. All rights reserved.
//

#import "DashboardViewController.h"

@interface DashboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *kpiNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *selectedTimePeriodKPILbl;
@property (weak, nonatomic) IBOutlet UILabel *kpiValueLbl;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UIView *avgValueIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *minValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *avgValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *maxValueLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avgIndicatorLeadingSpace;

@end

@implementation DashboardViewController

#pragma mark- View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set KPI name
    _kpiNameLbl.text = [_data valueForKey:@"label"];
    NSDictionary *kpiValue = [_data objectForKey:@"kpiValue"];
    NSDictionary *timePeriod = [kpiValue objectForKey:@"timePeriod"];
    
    //set KPI Value
    _kpiValueLbl.text = [NSString stringWithFormat:@"%@ %@",[[kpiValue valueForKey:@"amountInAggregationCurrency"] valueForKey:@"value"],[[kpiValue valueForKey:@"amountInAggregationCurrency"] valueForKey:@"unit"]];
    NSInteger days = [[timePeriod valueForKey:@"sliceUnitCount"]integerValue];
    
    //set timeperiod
    _selectedTimePeriodKPILbl.text = [NSString stringWithFormat:@"Last %ld day(s)",(long)days];
    
    //surrounding time period
    NSDictionary *surroundingPeriodData = [_data objectForKey:@"surroundingPeriodData"];
    
    //maximum value
    NSNumber *maxValue = [[[surroundingPeriodData valueForKey:@"maxValue"] valueForKey:@"amountInAggregationCurrency"] valueForKey:@"value"];
    //minimum value
    NSNumber *minValue = [[[surroundingPeriodData valueForKey:@"minValue"] valueForKey:@"amountInAggregationCurrency"] valueForKey:@"value"];
    //average value
    NSNumber *avgValue = [[[surroundingPeriodData valueForKey:@"avgValue"] valueForKey:@"amountInAggregationCurrency"] valueForKey:@"value"];
    
    //set minimum value
    _minValueLbl.text = [minValue stringValue];
    //set maximum value
    _maxValueLbl.text = [maxValue stringValue];
    //set average value
    _avgValueLbl.text = [avgValue stringValue];
    
    [self setBarWithMinimumValue:minValue maxValue:maxValue andAvgValue:avgValue];
    
}

#pragma mark- set Bar
//here we are setting the position of average value, postion of average value and indicator will be shifted depending upon min and max value
-(void)setBarWithMinimumValue : (NSNumber*)minValue maxValue : (NSNumber*)maxValue andAvgValue : (NSNumber*)avgValue{
    
    CGFloat dividedPoints = _barView.frame.size.width;
    
    CGFloat avgPointValue = (([avgValue doubleValue] - [minValue doubleValue])/([maxValue doubleValue]-[minValue doubleValue])) * dividedPoints;
    
    //change constraint to move
    _avgIndicatorLeadingSpace.constant = avgPointValue;
    
}

#pragma mark - back button action
- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
