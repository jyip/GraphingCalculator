//
//  CalculatorViewController.m
//  Calculator
//
//  Created by terran on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain; // model
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController

@synthesize display;
@synthesize brainDisplay;
@synthesize variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (NSDictionary *)testVariableValues
{
    if (!_testVariableValues) _testVariableValues = [[NSDictionary alloc] init];
    return _testVariableValues;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    //NSLog(@"user touched %@",digit);
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingFormat:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)pointPressed 
{
    if(self.userIsInTheMiddleOfEnteringANumber == NO) {
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringANumber = YES;
    } else if ([self.display.text rangeOfString:@"."].location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingFormat:@"."];
    }
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.brainDisplay.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

- (void)updateDisplay
{
    // display result
    double result = [CalculatorBrain runProgram:[self.brain program] usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    
    // display program description
    self.brainDisplay.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    
    // display variable values used in program
    NSSet *variablesUsedInProgram = [CalculatorBrain variablesUsedInProgram:[self.brain program]];
    self.variableDisplay.text = @"";
    for (NSString *key in variablesUsedInProgram) {
        NSNumber *objectValue = 0;
        NSString *stringFormat = @"";
        objectValue = [self.testVariableValues objectForKey:key];
        if (objectValue == nil) {
            stringFormat = @"%@ = %d  ";
        } else {
            stringFormat = @"%@ = %@  ";
        }
        
        self.variableDisplay.text = [self.variableDisplay.text stringByAppendingFormat:stringFormat, key, objectValue];
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    //NSLog(@"user touched %@",[sender currentTitle]);
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain pushOperand:[self.display.text doubleValue]];
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
    NSString *operation = [sender currentTitle];
    [self.brain pushOperation:operation];
    [self updateDisplay];
}

- (IBAction)variablePressed:(id)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
    NSString *variable = [sender currentTitle];
    [self.brain pushOperation:variable];
    [self updateDisplay];
    self.display.text = [NSString stringWithFormat:@"%@", variable];
}

- (IBAction)testPressed:(id)sender 
{
    NSString *test = [sender currentTitle];
    
    if ([test isEqualToString:@"Test 1"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:5], @"x",
                                   [NSNumber numberWithDouble:4.8], @"y",
                                   [NSNumber numberWithInt:0], @"foo", nil];
    } else if ([test isEqualToString:@"Test 2"]){
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:3], @"x",
                                   [NSNumber numberWithInt:-2], @"y",
                                   [NSNumber numberWithDouble:-0.73], @"foo", nil];
    } else if ([test isEqualToString:@"Test 3"]) {
        self.testVariableValues = nil;   
    }

    [self updateDisplay];
}

- (void)viewDidUnload {
    [self setBrainDisplay:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}

- (IBAction)signChangePressed 
{
    if ([self.display.text doubleValue] > 0) {
        self.display.text = [@"-" stringByAppendingString:self.display.text];
    } else if ([self.display.text doubleValue] < 0) {
        self.display.text = [self.display.text substringFromIndex:1];
    }
}

- (IBAction)clearPressed 
{
    self.brainDisplay.text = @"";
    self.display.text = @"0";
    self.variableDisplay.text = @"";
    [self.brain clearOperandStack];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.testVariableValues = nil;
}

- (IBAction)undoPressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber == YES) {
        self.display.text = [self.display.text substringToIndex:self.display.text.length - 1];

        if (self.display.text.length == 0) {
            [self updateDisplay];
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    } else {
        [self.brain removeLastObjectFromProgramStack];
        [self updateDisplay];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setProgram:[self.brain program]];
    }
}

- (GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (IBAction)setAndShowGraph {
    if ([self splitViewGraphViewController]) {
        [[self splitViewGraphViewController] setProgram:[self.brain program]];
    } else {
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


@end
