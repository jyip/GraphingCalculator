//
//  GraphView.m
//  GraphingCalculator
//
//  Created by terran on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;

#define DEFAULT_SCALE 10

- (CGFloat)scale
{
    if (!_scale) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:DEFAULT_SCALE forKey:@"scale"];
        [defaults synchronize];
        
        return DEFAULT_SCALE; // don't allow zero scale
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:scale forKey:@"scale"];
        [defaults synchronize];
        
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

- (CGPoint)origin
{
    if (_origin.x == 0 && _origin.y == 0) {
        _origin = self.center;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:_origin.x forKey:@"originX"];
        [defaults setFloat:_origin.y forKey:@"originY"];
        [defaults synchronize];
        
        return _origin;
    } else {
        return _origin;
    }
}

- (void)setOrigin:(CGPoint)origin
{
    if (origin.x != _origin.x && origin.y != _origin.y) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:origin.x forKey:@"originX"];
        [defaults setFloat:origin.y forKey:@"originY"];
        [defaults synchronize];
        
        _origin = origin;
        [self setNeedsDisplay];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
         (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        
        CGPoint newOrigin = self.origin;
        newOrigin.y += translation.y / 2;
        newOrigin.x += translation.x / 2;
        self.origin = newOrigin;
        
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.origin = [gesture locationInView:self];
    }
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
    // get user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGPoint defaultOrigin;
    CGFloat originX = [defaults floatForKey:@"originX"];
    CGFloat originY = [defaults floatForKey:@"originY"];
    defaultOrigin.x = originX;
    defaultOrigin.y = originY;
    self.origin = defaultOrigin;
    
    self.scale = [defaults floatForKey:@"scale"];
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}

- (float)convertForGraphX:(float)value
{
    return (value - self.origin.x) / self.scale;
}

- (float)convertForViewY:(float)value
{
    return -(value * self.scale - self.origin.y);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    [[UIColor grayColor] setStroke];
    
    // draw axes
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    
    //NSLog(@"%f, %f, %f", self.bounds.size.width, self.bounds.size.height, self.bounds.origin.y);
    
    // draw graph
    int started = NO;
    //NSLog(@"%f, %f", self.origin.x, self.origin.y);

    CGContextBeginPath(context);
    for (double viewX=0; viewX < self.bounds.size.width; viewX++) {
        double graphX = [self convertForGraphX:viewX];
        double graphY = [self.dataSource yValueForGraphView:self atX:graphX];
        double viewY = [self convertForViewY:graphY];
        
        if(viewY > self.bounds.size.height) continue;
        if(viewY < 0) continue;
        //NSLog(@"%f, %f, %f, %f", viewX, viewY, graphX, graphY);
        
        if (started == NO) {
            CGContextMoveToPoint(context, viewX, viewY);
            started = YES;
        } else {
            CGContextAddLineToPoint(context, viewX, viewY);
            CGContextMoveToPoint(context, viewX, viewY);
        }
    }
    CGContextStrokePath(context);
}

@end
