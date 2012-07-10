//
//  GraphViewController.m
//  GraphingCalculator
//
//  Created by terran on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"

@interface GraphViewController() <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController

@synthesize descriptionDisplay = _descriptionDisplay;
@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem; 

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return self ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{    
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

- (void)setProgram:(NSArray *)program
{
    _program = program;
    [self.graphView setNeedsDisplay];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    // set controller as delegate for GraphView datasource
    self.graphView.dataSource = self;
    
    // pinch
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    // pan
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    // tap
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapRecognizer];
    
    // set display after GraphView comes in so display shows on top
    self.descriptionDisplay.text = [CalculatorBrain descriptionOfProgram:self.program];
}

- (double)yValueForGraphView:(GraphView *)sender atX:(double)graphX
{       
    NSDictionary *variableValues = [NSDictionary dictionaryWithObjectsAndKeys: 
                                    [NSNumber numberWithFloat:graphX], @"x", nil];
    double graphY = [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
    
    return graphY;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setDescriptionDisplay:nil];
    [super viewDidUnload];
}

@end
