#import "GameViewController.h"
#import "MenuScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
//    skView.showsPhysics = YES;
    
    skView.ignoresSiblingOrder = YES;
    
    MenuScene *scene = [[MenuScene alloc] initWithSize:self.view.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    [skView presentScene:scene];
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeRight;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
    
}

@end
