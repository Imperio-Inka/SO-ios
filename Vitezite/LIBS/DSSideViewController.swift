//
//  DSSideViewController.swift
//  SideMenuTest
//
//  Created by Bhuvan Sharma on 10/16/15.
//  Copyright © 2015 Bhuvan Sharma. All rights reserved.
//

import UIKit

let DSSegueRearIdentifier = "DS_rear"
let DSSegueFrontIdentifier = "DS_front"
let DSSegueRightIdentifier = "DS_right"

class DSSideViewController: UIViewController,UIGestureRecognizerDelegate
{
    var _rearViewSideWidth:CGFloat=0.0
    var _rightViewSideWidth:CGFloat=0.0
    
    var _rearViewSideOverdraw:CGFloat=0.0
    var _rightViewSideOverdraw:CGFloat=0.0
    
    // Defines how much displacement is applied to the rear view when animating or dragging the front view, default is 40.
    var _rearViewSideDisplacement:CGFloat=0.0
    var _rightViewSideDisplacement:CGFloat=0.0
    
    // default is 0 which means no restriction.
    
    var _draggableBorderWidth:CGFloat=0.0
    
    // If YES (the default) the controller will bounce to the Left position when dragging further than 'rearViewDSWidth'
    var _bounceBackOnOverdraw:Bool=true
    
    var _bounceBackOnLeftOverdraw:Bool=true
    
    // If YES (default is NO) the controller will allow permanent dragging up to the rightMostPosition
    var _stableDragOnOverdraw:Bool=true
    var _stableDragOnLeftOverdraw:Bool=true
    
    var _presentFrontViewHierarchically:Bool=false
    
    var _quickFlickVelocity:CGFloat=0.0
    var _toggleAnimationDuration:NSTimeInterval=0.25
    
    
    
    // Animation type, default is SWDSToggleAnimationTypeSpring
    var _toggleAnimationType:SWDSToggleAnimationType!
    
    // When animation type is SWDSToggleAnimationTypeSpring determines the damping ratio, default is 1
    var _springDampingRatio:CGFloat=1.0
    
    
    // Duration for animated replacement of view controllers
    var _replaceViewAnimationDuration:NSTimeInterval=0.0
    
    
    // Defines the radius of the front view's shadow, default is 2.5f
    var _frontViewShadowRadius:CGFloat=2.5
    
    
    // Defines the radius of the front view's shadow offset default is {0.0f,2.5f}
    var _frontViewShadowOffset=CGSize(width: 0.0, height: 2.5)
    
    
    // Defines the front view's shadow opacity, default is 1.0f
    var _frontViewShadowOpacity:CGFloat=1.0
    
    
    // Defines the front view's shadow color, default is blackColor
    var _frontViewShadowColor:UIColor=UIColor.blackColor()
    
    var _clipsViewsToBounds:Bool=false
    
    var _extendsPointInsideHit:Bool=false
    
    var _delegate:DSSideViewControllerDelegate?
    
    
    var _contentView: DSSideView?
    var _panGestureRecognizer:UIPanGestureRecognizer!
    var _tapGestureRecognizer:UITapGestureRecognizer!
    
    var _frontViewPosition = FrontViewPosition.FrontViewPositionNone.rawValue
    var _rearViewPosition = FrontViewPosition.FrontViewPositionNone.rawValue
    var _rightViewPosition = FrontViewPosition.FrontViewPositionNone.rawValue
    
    var _rearTransitioningController:DSContextTransitionObject!
    var _frontTransitioningController:DSContextTransitionObject!
    var _rightTransitioningController:DSContextTransitionObject!
    
    var _panInitialFrontPosition = FrontViewPosition.FrontViewPositionNone.rawValue
    
    var _animationQueue : [FooCompletionHandler]
    var _userInteractionStore:Bool!
    
    // Rear view controller, can be nil if not used
    var _rearViewController:UIViewController?
    var _rightViewController:UIViewController?
    var _frontViewController:UIViewController?
    
    let  FrontViewPositionNone : Int = 0xff;
    
    //MARK: - Init
    
        required init(coder aDecoder: NSCoder)
        {
            _animationQueue = [FooCompletionHandler]()
            super.init(coder: aDecoder)!
            _initDefaultProperties()
        }
    
        init() {
            _animationQueue = [FooCompletionHandler]()
            super.init(nibName: nil, bundle: nil)
        }
    
    
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
            _animationQueue = [FooCompletionHandler]()
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
    
        convenience init(rearViewController:UIViewController,frontViewController:UIViewController){
            self.init()
            self._initDefaultProperties()
            self._performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceRearController, withViewController: rearViewController, animated1: false)
            _performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceFrontController, withViewController: frontViewController, animated1: false)
        }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return super.supportedInterfaceOrientations()
    }
    
    
    //MARK: - Public methods and property accessors
    
    func setFrontViewController(frontViewController: UIViewController)
    {
        setFrontViewController(frontViewController, animated: false)
    }
    
    
    
    func setFrontViewController(frontViewController: UIViewController,animated:Bool){
        
        if (!self.isViewLoaded())
        {
            self._performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceFrontController, withViewController: frontViewController, animated1: false)
            return;
        }
        self._dispatchTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceFrontController, withViewController: frontViewController, animated1: animated)
    }
    
    func setRearViewController(rearViewController: UIViewController)
    {
        setRearViewController(rearViewController, animated: false)
    }
    
    func setRearViewController(rearViewController: UIViewController,animated:Bool){
        
        if (!self.isViewLoaded())
        {
            self._performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceRearController, withViewController: rearViewController, animated1: false)
            return;
        }
        self._dispatchTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceRearController, withViewController: rearViewController, animated1: animated)
    }
    
    func setRightViewController(rightViewController: UIViewController)
    {
        setRightViewController(rightViewController, animated: false)
    }
    
    func setRightViewController(rightViewController: UIViewController,animated:Bool){
        
        if (!self.isViewLoaded())
        {
            self._performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceRightController, withViewController: rightViewController, animated1: false)
            return;
        }
        self._dispatchTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceRightController, withViewController: rightViewController, animated1: animated)
    }
    
    
    // Toogles the current state of the front controller between Left or Right and fully visible
    // Use setFrontViewPosition to set a particular position
    
    func DSToggleAnimated(animated:Bool){
        
        
        var toggledFrontViewPosition = FrontViewPosition.FrontViewPositionLeft.rawValue
        //print(_frontViewPosition)
        if (_frontViewPosition <= FrontViewPosition.FrontViewPositionLeft.rawValue){
            toggledFrontViewPosition = FrontViewPosition.FrontViewPositionRight.rawValue
        }
        self.setFrontViewPosition(toggledFrontViewPosition, animated: animated)
    }
    
    func rightDSToggleAnimated(animated:Bool)
    {
        var toggledFrontViewPosition = FrontViewPosition.FrontViewPositionLeft.rawValue
        
        if (_frontViewPosition >= FrontViewPosition.FrontViewPositionLeft.rawValue){
            toggledFrontViewPosition = FrontViewPosition.FrontViewPositionLeftSide.rawValue
        }
        self.setFrontViewPosition(toggledFrontViewPosition, animated: animated)
    }
    
    func setFrontViewPosition(frontViewPosition: NSInteger)
    {
        setFrontViewPosition(frontViewPosition, animated: false)
    }
    
    func setFrontViewPosition(frontViewPosition: NSInteger,animated:Bool){
        
        if (!self.isViewLoaded())
        {
            _frontViewPosition = frontViewPosition;
            _rearViewPosition = frontViewPosition;
            _rightViewPosition = frontViewPosition;
            return;
        }
        _dispatchSetFrontViewPosition(frontViewPosition, animated1: animated)
    }
    
    func setFrontViewShadowRadius(frontViewShadowRadius:CGFloat){
        _frontViewShadowRadius = frontViewShadowRadius;
        _contentView!.reloadShadow()
    }
    
    func setFrontViewShadowOffset(frontViewShadowOffset:CGSize){
        _frontViewShadowOffset = frontViewShadowOffset;
        _contentView?.reloadShadow()
    }
    
    func setFrontViewShadowOpacity(frontViewShadowOpacity:CGFloat){
        _frontViewShadowOpacity = frontViewShadowOpacity;
        _contentView!.reloadShadow()
    }
    
    func setFrontViewShadowColor(frontViewShadowColor:UIColor){
        _frontViewShadowColor = frontViewShadowColor;
        _contentView?.reloadShadow()
    }
    

    func panGestureRecognizer()->UIPanGestureRecognizer
    {
        if ( _panGestureRecognizer == nil )
        {
            _panGestureRecognizer = DSSideViewControllerPanGestureRecognizer(target: self, action: "_handleDSGesture:")
            
            _panGestureRecognizer.delegate = self;
            _contentView!._frontView!.addGestureRecognizer(_panGestureRecognizer)
        }
        return _panGestureRecognizer;
    }
    
    
    func tapGestureRecognizer()->UITapGestureRecognizer
    {
        if ( _tapGestureRecognizer == nil )
        {
            let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "_handleTapGesture:")
            
            tapRecognizer.delegate = self
            _contentView!._frontView!.addGestureRecognizer(tapRecognizer)
            _tapGestureRecognizer = tapRecognizer
        }
        return _tapGestureRecognizer;
    }
    
    func setClipsViewsToBounds(clipsViewsToBounds:Bool){
        _clipsViewsToBounds = clipsViewsToBounds
        _contentView!.clipsToBounds=clipsViewsToBounds
        
    }
    
    
    //MARK: - StatusBar
    
    override func childViewControllerForStatusBarStyle() -> UIViewController?{


        let positionDif =  _frontViewPosition - FrontViewPosition.FrontViewPositionLeft.rawValue
        var controller : UIViewController? = _frontViewController
        if ( positionDif > 0 ){
            controller = _rearViewController;
        }
        else if ( positionDif < 0 ){
            controller = _rightViewController;
        }

        return controller;
    }

    override func childViewControllerForStatusBarHidden()->UIViewController?
    {
        let controller: UIViewController? = self.childViewControllerForStatusBarStyle()
        return controller
    }
    
    func _initDefaultProperties()
    {
        _frontViewPosition = FrontViewPosition.FrontViewPositionLeft.rawValue;
        _rearViewPosition = FrontViewPosition.FrontViewPositionLeft.rawValue;
        _rightViewPosition = FrontViewPosition.FrontViewPositionLeft.rawValue;
        _rearViewSideWidth = UIScreen.mainScreen().bounds.size.width - 80*heightRatio;
        _rearViewSideOverdraw = 80*heightRatio;
        _rearViewSideDisplacement = 40.0;
        _rightViewSideWidth = UIScreen.mainScreen().bounds.size.width - 80*heightRatio;
        _rightViewSideOverdraw = 80*heightRatio;
        _rightViewSideDisplacement = 40.0;
        _bounceBackOnOverdraw = true;
        _bounceBackOnLeftOverdraw = true;
        _stableDragOnOverdraw = false;
        _stableDragOnLeftOverdraw = false;
        _presentFrontViewHierarchically =  false;
        _quickFlickVelocity = 250.0;
        _toggleAnimationDuration = 0.3;
        _toggleAnimationType = SWDSToggleAnimationType.SWDSToggleAnimationTypeSpring;
        _springDampingRatio = 1;
        _replaceViewAnimationDuration = 0.25;
        _frontViewShadowRadius = 2.5;
        _frontViewShadowOffset = CGSizeMake(0.0, 2.5);
        _frontViewShadowOpacity = 1.0;
        _frontViewShadowColor = UIColor.blackColor()
        _userInteractionStore = true;
        _animationQueue = [FooCompletionHandler]()
        _draggableBorderWidth = 0.0;
        _clipsViewsToBounds = false;
        _extendsPointInsideHit = false;
    }
    
    
    func _dequeue()
    {
        if ( _animationQueue.count > 0 )
        {
            let result = _animationQueue.removeLast()
        }
        
        if ( _animationQueue.count > 0 )
        {
            let block:()->Void = _animationQueue.last!
            block()
        }
    }
    
    
    func _enqueueBlock(block:()->Void)
    {
        _animationQueue.insert(block, atIndex: 0)
        if ( _animationQueue.count == 1)
        {
            block();
        }
    }
    
    
    func pushFrontViewController(frontViewController: UIViewController,animated:Bool)
    {
        if (!self.isViewLoaded())
        {
            _performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceFrontController, withViewController: frontViewController, animated1: false)
            return;
        }
        self._dispatchPushFrontViewController(frontViewController, animated1: animated)
    }
    

    
    @IBAction func DSToggle(sender: AnyObject) {
        
        self.DSToggleAnimated(true)
    }
    @IBAction func rightDSToggle(sender: AnyObject) {
        self.rightDSToggleAnimated(true)
        
    }
    
    func _disableUserInteraction()
    {
        _contentView!.userInteractionEnabled=false
        _contentView!.disableLayout=true
    }
    
    func _restoreUserInteraction()
    {
        _contentView!.userInteractionEnabled=_userInteractionStore
        _contentView!.disableLayout=false
    }
    
    // MARK: - - PanGesture progress notification
    
    func _notifyPanGestureBegan()
    {
        if (( _delegate?.respondsToSelector(Selector("DSControllerPanGestureBegan:")) ) != nil){
            _delegate?.DSControllerPanGestureBegan(self)
        }
        
        var xLocation: CGFloat = 0.0
        var dragProgress:CGFloat = 0.0
        var overProgress: CGFloat = 0.0
        
        _getDragLocationx(&xLocation, progress1: &dragProgress, overdrawProgress: &overProgress)
        
        if (( _delegate?.respondsToSelector(Selector("DSController(:,panGestureBeganFromLocation:,progress1:,overProgress1:)"))) != nil){
            _delegate?.DSController(self, panGestureBeganFromLocation: xLocation, progress1: dragProgress, overProgress1: overProgress)
        }
    }
    
    func _notifyPanGestureMoved()
    {
        
        var xLocation: CGFloat = 0.0
        var dragProgress:CGFloat = 0.0
        var overProgress: CGFloat = 0.0
        
        _getDragLocationx(&xLocation, progress1: &dragProgress, overdrawProgress: &overProgress)
        
        if (( _delegate?.respondsToSelector(Selector("DSController(:,panGestureMovedToLocation:,progress1:,overProgress1:)"))) != nil){
            _delegate?.DSController(self, panGestureMovedToLocation: xLocation, progress1: dragProgress, overProgress1: overProgress)
        }
        
    }
    
    func _notifyPanGestureEnded()
    {
        
        var xLocation: CGFloat = 0.0
        var dragProgress:CGFloat = 0.0
        var overProgress: CGFloat = 0.0
        
        _getDragLocationx(&xLocation, progress1: &dragProgress, overdrawProgress: &overProgress)
       // print("check progress and the end - \(xLocation) and overProgress - \(overProgress) and dragProgress- \(dragProgress)")
        if(_delegate?.respondsToSelector(Selector("DSController(:, panGestureEndedToLocation:,progress1:, overProgress1:)")) != nil)
        {
            _delegate?.DSController(self, panGestureEndedToLocation: xLocation, progress1: dragProgress, overProgress1: overProgress)
        }
    
        
        if ((_delegate?.respondsToSelector(Selector("DSControllerPanGestureEnded:"))) != nil){
            _delegate?.DSControllerPanGestureEnded(self)
        }
        
        
    }
    
    
    
    //MARK: - Symetry
    
    func _getDSWidth(inout pDSWidth:CGFloat,inout DSOverDraw pDSOverdraw:CGFloat,forSymetry symetry:Int)
    {
        if ( symetry < 0 ) {
            pDSWidth = _rightViewSideWidth
            pDSOverdraw = _rightViewSideOverdraw
        }
        else {
            pDSWidth = _rearViewSideWidth
            pDSOverdraw = _rearViewSideOverdraw
        }
        
        if (pDSWidth < 0)
        {
            pDSWidth = _contentView!.bounds.size.width + pDSWidth;
        }
    }
    
    func _getBounceBack(inout pBounceBack:Bool,inout pStableDrag1 pStableDrag:Bool,forSymetry symetry:Int)
    {
        if ( symetry < 0 )
        {
            pBounceBack = _bounceBackOnLeftOverdraw
            pStableDrag = _stableDragOnLeftOverdraw
        }
        else
        {
            pBounceBack = _bounceBackOnOverdraw
            pStableDrag = _stableDragOnOverdraw
        }
    }
    
    
    func _getAdjustedFrontViewPosition(inout frontViewPosition:NSInteger,forSymetry symetry:Int)
    {
        if ( symetry < 0 )
        {
            frontViewPosition = FrontViewPosition.FrontViewPositionLeft.rawValue + symetry*(frontViewPosition - FrontViewPosition.FrontViewPositionLeft.rawValue);
           // print(frontViewPosition)
        }
    }
    
    
    
    
    func _getDragLocationx(inout xLocation:CGFloat,inout progress1 progress:CGFloat)
    {
        let frontView : UIView = _contentView!._frontView!
        xLocation = frontView.frame.origin.x
        let symetry = xLocation<0 ? -1 :1
        var xWidth = symetry < 0 ? _rightViewSideWidth : _rearViewSideWidth
        if xWidth < 0 {
            xWidth = _contentView!.bounds.size.width + xWidth
        }
        
        progress = xLocation/xWidth * CGFloat(symetry)
    }
    
    
    
    
    func _getDragLocationx(inout xLocation:CGFloat, inout progress1 progress:CGFloat,inout overdrawProgress overProgress:CGFloat)
    {
        let frontView : UIView = _contentView!._frontView!
        xLocation = frontView.frame.origin.x
        let symetry = xLocation<0 ? -1 :1
        var xWidth = symetry < 0 ? _rightViewSideWidth : _rearViewSideWidth
        let xOverWidth = symetry < 0 ? _rightViewSideOverdraw : _rearViewSideOverdraw;
        if xWidth < 0
        {
            xWidth = _contentView!.bounds.size.width + xWidth
        }
        
        progress = xLocation * CGFloat(symetry)/xWidth;
        overProgress = (xLocation * CGFloat(symetry)-xWidth)/xOverWidth;
        
        
    }
    
    // MARK: - Gesture Delegate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if(_animationQueue.count == 0)
        {
            if ( gestureRecognizer == _panGestureRecognizer ){
                return self._panGestureShouldBegin()
            }
            if ( gestureRecognizer == _tapGestureRecognizer ){
                
                return self._tapGestureShouldBegin()
            }
            
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer:UIGestureRecognizer ) -> Bool {
        
        
        if ( gestureRecognizer == _panGestureRecognizer ){
            
            
            if (( _delegate?.respondsToSelector(Selector("DSController(:,panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:)"))) != nil){
                
                if ( _delegate?.DSController(self, panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer) != false ){
                    
                    return true
                }
            }
        }
        
        else if ( gestureRecognizer == _tapGestureRecognizer ){
            
            
            if (( _delegate?.respondsToSelector(Selector("DSController(:,tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:)"))) != nil){
                
                if ( _delegate?.DSController(self, tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer) != false ){
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    
    func _tapGestureShouldBegin()->Bool
    {
        if ( _frontViewPosition == FrontViewPosition.FrontViewPositionLeft.rawValue ||
            _frontViewPosition == FrontViewPosition.FrontViewPositionRightMostRemoved.rawValue ||
            _frontViewPosition == FrontViewPosition.FrontViewPositionLeftSideMostRemoved.rawValue ){
                return false
        }
        
        // forbid gesture if the following delegate is implemented and returns NO
        if (( _delegate?.respondsToSelector(Selector("DSControllerTapGestureShouldBegin(:)"))) != nil){
            if (_delegate?.DSControllerTapGestureShouldBegin(self) == false ){
                return false
            }
        }
        return true;
        
    }
    
    
    func _panGestureShouldBegin()->Bool
    {
        let recognizerView:UIView = _panGestureRecognizer.view!
        let translation: CGPoint = _panGestureRecognizer.translationInView(recognizerView)
        if ((_delegate?
            .respondsToSelector("DSControllerPanGestureShouldBegin(:)")) != nil)
        {
            if (_delegate?.DSControllerPanGestureShouldBegin(self) == false )
            {
                return false
            }
        }
        
        let xLocation:CGFloat = _panGestureRecognizer.locationInView(recognizerView).x
        let width = recognizerView.bounds.size.width
        
        let  draggableBorderAllowing = (_draggableBorderWidth == 0.0) ||
            (_rearViewController != nil && xLocation <= _draggableBorderWidth) || (_rightViewController != nil && xLocation >= (width - _draggableBorderWidth))
        
        let translationForbidding = ( _frontViewPosition == FrontViewPosition.FrontViewPositionLeft.rawValue &&
            ((_rearViewController == nil && translation.x > 0) || (_rightViewController == nil && translation.x < 0)) );
        
        // allow gesture only within the bounds defined by the draggableBorderWidth property
        return draggableBorderAllowing && !translationForbidding ;
    }
    
    /* The class properly handles all the relevant calls to appearance methods on the contained controllers.
    Moreover you can assign a delegate to let the class inform you on positions and animation activity */
    
    // Delegate
    //var delegate: DSSideViewControllerDelegate?
    
    
    //MARK - Gesture Based DS
    
    func _handleTapGesture(recognizer:UITapGestureRecognizer){
        let duration:NSTimeInterval = _toggleAnimationDuration;
        self._setFrontViewPosition(FrontViewPosition.FrontViewPositionLeft.rawValue, withDuration: duration)
    }
    
    func _handleDSGesture(recognizer:UIPanGestureRecognizer){
        
        switch ( recognizer.state)
        {
        case UIGestureRecognizerState.Began:
            self._handleDSGestureStateBeganWithRecognizer(recognizer)
            break
        case UIGestureRecognizerState.Changed:
            self._handleDSGestureStateChangedWithRecognizer(recognizer)
            break
        case UIGestureRecognizerState.Ended:
            self._handleDSGestureStateEndedWithRecognizer(recognizer)
            break
        case UIGestureRecognizerState.Cancelled:
            self._handleDSGestureStateCancelledWithRecognizer(recognizer)
            break
        default: break
        }
    }
    
    func _handleDSGestureStateBeganWithRecognizer(recognizer:UIPanGestureRecognizer){
        
        self._enqueueBlock({})
        _panInitialFrontPosition = _frontViewPosition;
        self._disableUserInteraction()
        self._notifyPanGestureBegan()
    }
    
    func _handleDSGestureStateChangedWithRecognizer(recognizer:UIPanGestureRecognizer){
        
        let translate : CGFloat = recognizer.translationInView(_contentView).x
        let baseLocation : CGFloat = _contentView!.frontLocationForPosition(_panInitialFrontPosition)
        var xLocation = baseLocation + translate
        
        if(xLocation < 0)
        {
            if(_rightViewController == nil){
                xLocation = 0
            }
            self._rightViewDeploymentForNewFrontViewPosition(FrontViewPosition.FrontViewPositionLeftSide.rawValue)()
            self._rearViewDeploymentForNewFrontViewPosition(FrontViewPosition.FrontViewPositionLeftSide.rawValue)()
            
        }
        
        if(xLocation > 0)
        {
            if(_rearViewController == nil){
                xLocation = 0
            }
            self._rightViewDeploymentForNewFrontViewPosition(FrontViewPosition.FrontViewPositionRight.rawValue)()
            self._rearViewDeploymentForNewFrontViewPosition(FrontViewPosition.FrontViewPositionRight.rawValue)()
            
        }
        
        _contentView!.dragFrontViewToXLocation(xLocation)
        self._notifyPanGestureMoved()
    }
    
    func _handleDSGestureStateEndedWithRecognizer(recognizer:UIPanGestureRecognizer){
        
        let frontView: UIView = _contentView!._frontView!
        var xLocation: CGFloat = frontView.frame.origin.x
        let velocity: CGFloat = recognizer.velocityInView(_contentView).x
        
        let symetry = xLocation < 0 ? -1 : 1
        
        var DSWidth: CGFloat = 0.0
        var DSOverDraw: CGFloat = 0.0
        var bouncBack: Bool = false
        var stableDrag: Bool = false
        
        self._getDSWidth(&DSWidth, DSOverDraw: &DSOverDraw, forSymetry: symetry)
        self._getBounceBack(&bouncBack, pStableDrag1: &stableDrag, forSymetry: symetry)
        
        xLocation = xLocation * CGFloat(symetry)
        
        var fronViewPostion1  = FrontViewPosition.FrontViewPositionLeft.rawValue
        var duration: NSTimeInterval = _toggleAnimationDuration
        
        if(fabs(velocity) > _quickFlickVelocity )
        {
            var journey: CGFloat = xLocation
            if (velocity * CGFloat(symetry)>0.0)
            {
                fronViewPostion1 = FrontViewPosition.FrontViewPositionRight.rawValue
                journey = DSWidth - xLocation
                if(xLocation > DSWidth){
                    
                    if(!bouncBack && stableDrag)
                    {
                        fronViewPostion1 = FrontViewPosition.FrontViewPositionRightMost.rawValue
                        journey = DSWidth + DSOverDraw - xLocation
                    }
                }
            }
            duration = fabs(journey.dvalue/velocity.dvalue);
            
        }
        else
        {
            if(xLocation > DSWidth*0.5)
            {
                fronViewPostion1 = FrontViewPosition.FrontViewPositionRight.rawValue;
                if (xLocation > DSWidth)
                {
                    if (bouncBack){
                        fronViewPostion1 = FrontViewPosition.FrontViewPositionLeft.rawValue;
                    }
                    else if(stableDrag && xLocation > DSWidth + DSOverDraw * 0.5){
                        fronViewPostion1 = FrontViewPosition.FrontViewPositionRightMost.rawValue  ;
                    }
                    
                }
                
            }
        }
        
        // symetric replacement of frontViewPosition
        
        self._getAdjustedFrontViewPosition(&fronViewPostion1, forSymetry: symetry)
        
   // print("front position value: \(fronViewPostion1)")
        
        self._restoreUserInteraction()
        self._notifyPanGestureEnded()
        self._setFrontViewPosition(fronViewPostion1, withDuration: duration)
        
    }
    
    func _handleDSGestureStateCancelledWithRecognizer(recognizer:UIPanGestureRecognizer){
        self._restoreUserInteraction()
        self._notifyPanGestureEnded()
        self._dequeue()
    }
    
    //MARK: Enqueued position and controller setup
    
    func _dispatchTransitionOperation(operation:DSSideControllerOperation,withViewController newViewController:UIViewController, animated1 animated:Bool){
        
        self._enqueueBlock({self._performTransitionOperation(operation, withViewController: newViewController, animated1: animated)})
    }
    
    func _dispatchPushFrontViewController(newFrontViewController:UIViewController, animated1 animated:Bool)
    {
        var preReplacementPosition = FrontViewPosition.FrontViewPositionLeft.rawValue
        if(_frontViewPosition > FrontViewPosition.FrontViewPositionLeft.rawValue)
        {
            preReplacementPosition = FrontViewPosition.FrontViewPositionRightMost.rawValue
        }
        
        if(_frontViewPosition < FrontViewPosition.FrontViewPositionLeft.rawValue)
        {
            preReplacementPosition = FrontViewPosition.FrontViewPositionLeftSideMost.rawValue
        }
        
        let duration: NSTimeInterval = animated ? _toggleAnimationDuration : 0.0
        var firstDuration : NSTimeInterval = duration
        
        let initialPosDif = abs(_frontViewPosition - preReplacementPosition)
        if(initialPosDif == 1 )
        {
            firstDuration = firstDuration * 0.8
        }
        else if(initialPosDif == 0){
            firstDuration = 0
        }
        
        
        if ( animated )
        {
            _enqueueBlock({self._setFrontViewPosition(preReplacementPosition, withDuration: firstDuration)})
            _enqueueBlock({self._performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceFrontController, withViewController: newFrontViewController, animated1: false)})
            _enqueueBlock({self._setFrontViewPosition(FrontViewPosition.FrontViewPositionLeft.rawValue, withDuration: duration)})
            
        }
        else
        {
            _enqueueBlock({self._performTransitionOperation(DSSideControllerOperation.DSSideControllerOperationReplaceFrontController, withViewController: newFrontViewController, animated1: false)})
        }
        
        
    }
    
    
    func _dispatchSetFrontViewPosition(frontViewPosition:NSInteger, animated1 animated:Bool){
        
        let duration:NSTimeInterval = animated ? _toggleAnimationDuration : 0.0;
       // print(frontViewPosition)
        self._enqueueBlock({self._setFrontViewPosition(frontViewPosition, withDuration: duration)})
    }
    
    //MARK: Animated view controller deployment and layout
    // Primitive method for view controller deployment and animated layout to the given position.
    func _setFrontViewPosition(newPosition:NSInteger,withDuration duration: NSTimeInterval){
        
        NSNotificationCenter.defaultCenter().postNotificationName("SideMenuChange", object: nil)
        let rearDeploymentCompletion:()->Void = _rearViewDeploymentForNewFrontViewPosition(newPosition)
        
        let rightDeploymentCompletion:()->Void = _rightViewDeploymentForNewFrontViewPosition(newPosition)
        
        let frontDeploymentCompletion:()->Void = _frontViewDeploymentForNewFrontViewPosition(newPosition)
        
        let animations:()->Void = {
            ()->() in
            self.setNeedsStatusBarAppearanceUpdate()
            self._contentView!.layoutSubviews()
            
            if((self._delegate?.respondsToSelector(Selector("DSController(:,animateToPosition:)"))) != nil)
            {
                self._delegate?.DSController(self, animateToPosition: self._frontViewPosition)
            }
            
        }
        
        let completion:(finish:Bool)->Void = {(finish: Bool)->() in
            rearDeploymentCompletion()
            rightDeploymentCompletion()
            frontDeploymentCompletion()
            self._dequeue()
        }
        
        
        if ( duration > 0.0 )
        {
            if ( _toggleAnimationType == SWDSToggleAnimationType.SWDSToggleAnimationTypeEaseOut)
            {
                UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: animations, completion: completion)
            }
            else
            {
                UIView.animateWithDuration(_toggleAnimationDuration, delay: 0.0, usingSpringWithDamping: _springDampingRatio, initialSpringVelocity: CGFloat(1/duration), options: UIViewAnimationOptions.init(rawValue: 0), animations: animations, completion: completion)
            }
        }
        else
        {
            animations();
            completion(finish: true);
        }
        
        
    }
    
    // Primitive method for animated controller transition
    func _performTransitionOperation(operation:DSSideControllerOperation,withViewController new:UIViewController, animated1 animated:Bool)
    {
        if((_delegate?.respondsToSelector(Selector("DSController:willAddViewController:forOperation:animated1:"))) != nil)
        {
            _delegate?.DSController(self, willAddViewController: new, forOperation: operation, animated1: animated)
        }
        
        
        var old : UIViewController? = nil
        var view : UIView? = nil
        
        if ( operation == DSSideControllerOperation.DSSideControllerOperationReplaceRearController ){
            old = _rearViewController
            _rearViewController = new
            view = _contentView?._rearView
        }
            
        else if ( operation == DSSideControllerOperation.DSSideControllerOperationReplaceFrontController ){
            
            old = _frontViewController
            _frontViewController = new
            view = _contentView?._frontView
        }
            
            
        else if ( operation == DSSideControllerOperation.DSSideControllerOperationReplaceRightController ){
            
            old = _rightViewController
            _rightViewController = new
            view = _contentView?._rightView
        }
        
        let completionHandler:()->Void = _transitionFromViewController(old, toViewController: new, inView: view)
        
        let animationCompletion:()->Void = { () -> ()in completionHandler()
            
            if((self._delegate?.respondsToSelector(Selector("DSController:didAddViewController:forOperation:animated1:"))) != nil)
            {
                self._delegate?.DSController(self, didAddViewController: new, forOperation: operation, animated1: animated)
            }
            self._dequeue()
        }
        
        
        if ( animated )
        {
            var animationController: UIViewControllerAnimatedTransitioning? = nil
            
            if((self._delegate?.respondsToSelector(Selector("DSController(:,animationControllerForOperation:,fromViewController:,toViewController:)"))) != nil)
            {
                self._delegate?.DSController(self, forOperation: operation, fromViewController: old!, toViewController: new)
            }
            
            
            
            if ((animationController ) != nil){
                animationController = SWDefaultAnimationController(duration: _replaceViewAnimationDuration)
            }
            
            let transitioningObject: DSContextTransitionObject = DSContextTransitionObject(DSVC: self, containerView: view!, fromVC: old!, toVC: new, completion: animationCompletion)
            
            if (animationController?.transitionDuration(transitioningObject) > 0 ){
                
                animationController?.animateTransition(transitioningObject)
            }
            else{
                
            }
            animationCompletion();
        }
        else
        {
            animationCompletion();
        }
        
    }
    
    func _frontViewDeploymentForNewFrontViewPosition(var newPosition:NSInteger)->()->Void
    {
        if ( (_rightViewController == nil && newPosition < FrontViewPosition.FrontViewPositionLeft.rawValue) ||
            (_rearViewController == nil && newPosition > FrontViewPosition.FrontViewPositionLeft.rawValue) )
        {
                newPosition = FrontViewPosition.FrontViewPositionLeft.rawValue
        }
        let positionIsChanging:Bool = (_frontViewPosition != newPosition)
        
        let appear:Bool = (_frontViewPosition >= FrontViewPosition.FrontViewPositionRightMostRemoved.rawValue || _frontViewPosition <= FrontViewPosition.FrontViewPositionLeftSideMostRemoved.rawValue || _frontViewPosition == FrontViewPosition.FrontViewPositionNone.rawValue) &&
            (newPosition < FrontViewPosition.FrontViewPositionRightMostRemoved.rawValue && newPosition > FrontViewPosition.FrontViewPositionLeftSideMostRemoved.rawValue);
        let disappear:Bool =
        (newPosition >= FrontViewPosition.FrontViewPositionRightMostRemoved.rawValue || newPosition <= FrontViewPosition.FrontViewPositionLeftSideMostRemoved.rawValue ) &&
            (_frontViewPosition < FrontViewPosition.FrontViewPositionRightMostRemoved.rawValue && _frontViewPosition > FrontViewPosition.FrontViewPositionLeftSideMostRemoved.rawValue && _frontViewPosition != FrontViewPosition.FrontViewPositionNone.rawValue);
        if ( positionIsChanging )
        {
            if((_delegate?.respondsToSelector("DSController(:,willMoveToPosition:)")) != nil)
            {
                _delegate?.DSController(self, willMoveToPosition: newPosition)
            }
        }
        _frontViewPosition = newPosition;
        
        let deploymentCompletion:()->Void = _deploymentForViewController(_frontViewController, inView: _contentView!._frontView, appear1: appear, disappear1: disappear)
        
        let completion:()->Void =
        {()->() in
            deploymentCompletion();
            
            
            if ( positionIsChanging )
            {
                
                if((self._delegate?.respondsToSelector("DSController(:,didMoveToPosition:)")) != nil)
                {
                    self._delegate?.DSController(self, didMoveToPosition: newPosition)
                }
            }
        };
        
        return completion;
        
    }
    
    func _rearViewDeploymentForNewFrontViewPosition(var newPosition:NSInteger)->()->Void
    {
        if ( _presentFrontViewHierarchically )
        {
            newPosition = FrontViewPosition.FrontViewPositionRight.rawValue
        }
        
        if ( _rearViewController == nil && newPosition > FrontViewPosition.FrontViewPositionLeft.rawValue )
        {
            newPosition = FrontViewPosition.FrontViewPositionLeft.rawValue;
        }
        
        let appear: Bool = (_rearViewPosition <= FrontViewPosition.FrontViewPositionLeft.rawValue || _rearViewPosition == FrontViewPosition.FrontViewPositionNone.rawValue) && newPosition > FrontViewPosition.FrontViewPositionLeft.rawValue
        let disappear: Bool = newPosition <= FrontViewPosition.FrontViewPositionLeft.rawValue && (_rearViewPosition > FrontViewPosition.FrontViewPositionLeft.rawValue && _rearViewPosition != FrontViewPosition.FrontViewPositionNone.rawValue);
        if appear
        {
            _contentView!.prepareRearViewForPosition(newPosition)
        }
        _rearViewPosition = newPosition
        return _deploymentForViewController(_rearViewController, inView: _contentView!._rearView, appear1: appear, disappear1: disappear)
    }
    
    func _rightViewDeploymentForNewFrontViewPosition(var newPosition:NSInteger)->()->Void
    {
        if ( _rightViewController == nil && newPosition < FrontViewPosition.FrontViewPositionLeft.rawValue ){
            newPosition = FrontViewPosition.FrontViewPositionLeft.rawValue;
        }
        
        let appear: Bool = (_rightViewPosition >= FrontViewPosition.FrontViewPositionLeft.rawValue || _rightViewPosition == FrontViewPosition.FrontViewPositionNone.rawValue) && newPosition < FrontViewPosition.FrontViewPositionLeft.rawValue ;
        
        let disappear:Bool = newPosition >= FrontViewPosition.FrontViewPositionLeft.rawValue && (_rightViewPosition < FrontViewPosition.FrontViewPositionLeft.rawValue && _rightViewPosition != FrontViewPosition.FrontViewPositionNone.rawValue);
        
        if ( appear )
        {
            _contentView!.prepareRightViewForPosition(newPosition)
        }
        
        
        _rightViewPosition = newPosition;
        return _deploymentForViewController(_rightViewController, inView: _contentView!._rightView, appear1: appear, disappear1: disappear)
    }
    
    
    
    func _deploymentForViewController(controller:UIViewController?, inView view:UIView?, appear1 appear:Bool, disappear1 disappear:Bool)->()->Void
    {
        if ( appear ){
            return _deployForViewController(controller, inView: view)
        }
        if ( disappear ){
            return _undeployForViewController(controller)
        }
        return {()->() in }
    }
    
    //MARK: Containment view controller deployment and transition

    func _deployForViewController(controller:UIViewController?,inView view:UIView?)->()->Void
    {
        if (controller == nil || view == nil )
        {
            return {()->() in}
        }
        
        let frame:CGRect = view!.bounds
        let controllerView: UIView = controller!.view
        controllerView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        controllerView.frame=frame
        
        if(controllerView.isKindOfClass(UIScrollView))
        {
            let adjust: Bool = controller!.automaticallyAdjustsScrollViewInsets
            
            if adjust
            {
                (controllerView as! UIScrollView).contentInset = UIEdgeInsetsMake(statusBar.statusBarAdjustment(_contentView!), 0, 0, 0)
                
            }
        }
        view!.addSubview(controllerView)
        let completionBlock:()->Void = {() in
        }
        return completionBlock
    }
    
    func _undeployForViewController(controller:UIViewController?)->()->Void{
        
        if (controller == nil)
        {
            return {()->() in
            }
        }
        
        let completionBlock:()->Void = {() in
            controller!.view.removeFromSuperview()
        }
        return completionBlock;
    }
    
    func _transitionFromViewController(fromController:UIViewController?, toViewController toController:UIViewController?,inView view:UIView?)->()->Void{
        
        if ( fromController == toController ){
            return {()->() in }
        }
        
        if (toController != nil)
        {
            addChildViewController(toController!)
        }
        
        
        let deployCompletion:()->Void = _deployForViewController(toController!,inView:view)
        let vieCt: UIViewController? = nil
        fromController?.willMoveToParentViewController(vieCt)
        
        let undeployCompletion:()->Void = _undeployForViewController(fromController)
        
        
        let completionBlock:()->Void = {() in
            
            undeployCompletion() ;
            fromController?.removeFromParentViewController()
            
            deployCompletion() ;
            toController!.didMoveToParentViewController(self)
        };
        return completionBlock;
        
        
    }
    
    func loadStoryboardControllers()
    {
        
        if ( self.storyboard != nil && _rearViewController == nil )
        {

            do{
                try self.performSegueWithIdentifier(DSSegueRearIdentifier as String, sender: nil)
            }catch
            {
                
            }
            do{
                try performSegueWithIdentifier(DSSegueFrontIdentifier as String, sender: nil)
            }catch
            {
                
            }
//            do{
//                try performSegueWithIdentifier(DSSegueRightIdentifier as String, sender: nil)
//            }catch
//            {
//                
//            }
        }
        
        
    }
    
    //MARK: state preservation / restoration
    
    class func viewControllerWithRestorationIdentifierPath(identifierComponents:NSArray, coder1 coder:NSCoder) -> UIViewController
    {
        var vc: DSSideViewController? = nil
        
        let sb: UIStoryboard? = coder.decodeObjectForKey(UIStateRestorationViewControllerStoryboardKey) as? UIStoryboard
        if(sb != nil)
        {
            vc = sb?.instantiateViewControllerWithIdentifier("DSSideViewController") as? DSSideViewController
            vc!.restorationIdentifier = identifierComponents.lastObject as? String
            vc!.restorationClass = DSSideViewController.self
        }
        return vc!
    }
    
    
    override func encodeRestorableStateWithCoder(coder: NSCoder)
    {
        coder.encodeDouble(_rearViewSideWidth.dvalue, forKey: "_rearViewSideWidth")
        coder.encodeDouble(_rearViewSideOverdraw.dvalue, forKey: "_rearViewSideOverdraw")
        coder.encodeDouble(_rearViewSideDisplacement.dvalue, forKey: "_rearViewSideDisplacement")
        coder.encodeDouble(_rightViewSideWidth.dvalue, forKey: "_rightViewSideWidth")
        coder.encodeDouble(_rightViewSideOverdraw.dvalue, forKey: "_rightViewSideOverdraw")
        coder.encodeDouble(_rightViewSideDisplacement.dvalue, forKey: "_rightViewSideDisplacement")
        
        coder.encodeDouble(_quickFlickVelocity.dvalue, forKey: "_quickFlickVelocity")
        coder.encodeDouble(_toggleAnimationDuration, forKey: "_toggleAnimationDuration")
        
        coder.encodeDouble(_springDampingRatio.dvalue, forKey: "_springDampingRatio")
        coder.encodeDouble(_replaceViewAnimationDuration, forKey: "_replaceViewAnimationDuration")
        coder.encodeDouble(_frontViewShadowRadius.dvalue, forKey: "_frontViewShadowRadius")
        
        coder.encodeDouble(_frontViewShadowOpacity.dvalue, forKey: "_frontViewShadowOpacity")
        coder.encodeDouble(_draggableBorderWidth.dvalue, forKey: "_draggableBorderWidth")
        
        
        coder.encodeBool(_bounceBackOnOverdraw, forKey: "_bounceBackOnOverdraw")
        coder.encodeBool(_bounceBackOnLeftOverdraw, forKey: "_bounceBackOnLeftOverdraw")
        coder.encodeBool(_stableDragOnOverdraw, forKey: "_stableDragOnOverdraw")
        coder.encodeBool(_stableDragOnLeftOverdraw, forKey: "_stableDragOnLeftOverdraw")
        coder.encodeBool(_presentFrontViewHierarchically, forKey: "_presentFrontViewHierarchically")
        
        coder.encodeBool(_userInteractionStore, forKey: "_userInteractionStore")
        coder.encodeBool(_clipsViewsToBounds, forKey: "_clipsViewsToBounds")
        coder.encodeBool(_extendsPointInsideHit, forKey: "_extendsPointInsideHit")
        
        
        coder.encodeInteger(_toggleAnimationType.rawValue, forKey: "_toggleAnimationType")
        coder.encodeInteger(_frontViewPosition, forKey: "_frontViewPosition")
        
        coder.encodeObject(_frontViewShadowColor, forKey: "_frontViewShadowColor")
        coder.encodeObject(_rearViewController, forKey: "_rearViewController")
        coder.encodeObject(_frontViewController, forKey: "_frontViewController")
        coder.encodeObject(_rightViewController, forKey: "_rightViewController")
        
        coder.encodeCGSize(_frontViewShadowOffset, forKey: "_frontViewShadowOffset")
        
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder)
    {
        _rearViewSideWidth = coder.decodeDoubleForKey("_rearViewSideWidth").cfValue
        _rearViewSideOverdraw = coder.decodeDoubleForKey("_rearViewSideOverdraw").cfValue
        _rearViewSideDisplacement = coder.decodeDoubleForKey("_rearViewSideDisplacement").cfValue
        _rightViewSideWidth = coder.decodeDoubleForKey("_rightViewSideWidth").cfValue
        _rightViewSideOverdraw = coder.decodeDoubleForKey("_rightViewSideOverdraw").cfValue
        _rightViewSideDisplacement = coder.decodeDoubleForKey("_rightViewSideDisplacement").cfValue
        
        _bounceBackOnOverdraw = coder.decodeBoolForKey("_bounceBackOnOverdraw")
        _bounceBackOnLeftOverdraw = coder.decodeBoolForKey("_bounceBackOnLeftOverdraw")
        _stableDragOnOverdraw = coder.decodeBoolForKey("_stableDragOnOverdraw")
        _stableDragOnLeftOverdraw = coder.decodeBoolForKey("_stableDragOnLeftOverdraw")
        _presentFrontViewHierarchically = coder.decodeBoolForKey("_presentFrontViewHierarchically")
        _quickFlickVelocity = coder.decodeDoubleForKey("_quickFlickVelocity").cfValue
        _toggleAnimationDuration = coder.decodeDoubleForKey("_toggleAnimationDuration")
        //_toggleAnimationType = coder.decodeIntegerForKey("_toggleAnimationType") as SWDSToggleAnimationType
        _springDampingRatio = coder.decodeDoubleForKey("_springDampingRatio").cfValue
        _replaceViewAnimationDuration = coder.decodeDoubleForKey("_replaceViewAnimationDuration")
        _frontViewShadowRadius = coder.decodeDoubleForKey("_frontViewShadowRadius").cfValue
        _frontViewShadowOffset = coder.decodeCGSizeForKey("_frontViewShadowOffset")
        _frontViewShadowOpacity = coder.decodeDoubleForKey("_frontViewShadowOpacity").cfValue
        _frontViewShadowColor = coder.decodeObjectForKey("_frontViewShadowColor") as! UIColor
        _userInteractionStore = coder.decodeBoolForKey("_userInteractionStore")
        _animationQueue = [FooCompletionHandler]()
        _draggableBorderWidth = coder.decodeDoubleForKey("_draggableBorderWidth").cfValue
        _clipsViewsToBounds = coder.decodeBoolForKey("_clipsViewsToBounds")
        _extendsPointInsideHit = coder.decodeBoolForKey("_extendsPointInsideHit")
        
        self.setRearViewController(coder.decodeObjectForKey("_rearViewController") as! UIViewController)
        self.setFrontViewController(coder.decodeObjectForKey("_frontViewController") as! UIViewController)
        self.setRightViewController(coder.decodeObjectForKey("_rightViewController") as! UIViewController)
        
        self.setFrontViewPosition(coder.decodeIntegerForKey("_frontViewPosition"))
        
        super.decodeRestorableStateWithCoder(coder)
    }
    
    override func applicationFinishedRestoringState()
    {
        
    }
    
    override func loadView()
    {
        
        
        self.loadStoryboardControllers()
        let frame:CGRect = UIScreen.mainScreen().bounds
        
        // create a custom content view for the controller
        _contentView = DSSideView(frame: frame, controller1: self)
        
        // set the content view to resize along with its superview
        _contentView!.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        _contentView!.clipsToBounds = _clipsViewsToBounds
        
        // set our contentView to the controllers view
        self.view = _contentView;

        // Apple also tells us to do this:
        _contentView!.backgroundColor = UIColor.blackColor()
        
        let  initialPosition = _frontViewPosition;
        _frontViewPosition = FrontViewPosition.FrontViewPositionNone.rawValue;
        _rearViewPosition = FrontViewPosition.FrontViewPositionNone.rawValue;
        _rightViewPosition = FrontViewPosition.FrontViewPositionNone.rawValue;
        
        // now set the desired initial position
        self._setFrontViewPosition(initialPosition, withDuration: 0.0)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        _userInteractionStore = _contentView!.userInteractionEnabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


struct statusBar {
    static func statusBarAdjustment(view: UIView) -> CGFloat
    {
        var adjustment: CGFloat = 0.0
        let app: UIApplication = UIApplication.sharedApplication()
        let viewFrame:CGRect = view.convertRect(view.bounds, toView: app.keyWindow)
        let statusBarFrame : CGRect = app.statusBarFrame
        if CGRectIntersectsRect(viewFrame, statusBarFrame){
            adjustment = fminf(statusBarFrame.size.width.swf , statusBarFrame.size.height.swf).fvalue
        }
        return adjustment
    }
}

// MARK: DSSideView Class

class DSSideView : UIView
{
    weak var _c :DSSideViewController!
    var _rearView: UIView?
    var _rightView: UIView?
    var _frontView: UIView?
    var disableLayout: Bool! = false
    
    
    struct scaled {
        static func Value(v1:CGFloat,min2:CGFloat,max2:CGFloat,min1:CGFloat,max1:CGFloat) -> CGFloat
        {
            let result:CGFloat = min2 + (v1-min1)*((max2-min2)/(max1-min1));
            if ( result != result ){
                return min2
            }
            if ( result < min2 )
            {
                return min2
            }
            if ( result > max2 )
            {
                return max2
            }
            return result
        }
    }
    
    init(frame: CGRect,controller1 controller:DSSideViewController )    {
        super.init(frame: frame)
        _c = controller
        let bounds : CGRect = self.bounds
        _frontView = UIView(frame: bounds)
        _frontView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        reloadShadow()
        self.addSubview(_frontView!)
        
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func reloadShadow()
    {
        let frontViewLayer: CALayer = _frontView!.layer
        frontViewLayer.shadowColor = _c._frontViewShadowColor.CGColor
        frontViewLayer.shadowOpacity = _c._frontViewShadowOpacity.swf
        frontViewLayer.shadowOffset = _c._frontViewShadowOffset
        frontViewLayer.shadowRadius = _c._frontViewShadowRadius
    }
    
    func hierarchycalFrameAdjustment(var frame: CGRect)->CGRect
    {
        if(_c._presentFrontViewHierarchically)
        {
            let dummyBar: UINavigationBar = UINavigationBar()
            let barHeight: CGFloat = dummyBar.sizeThatFits(CGSizeMake(100, 100)).height
            let offset = barHeight + statusBar.statusBarAdjustment(self)
            frame.origin.y += offset
            frame.size.height -= offset
        }
        return frame
    }
    
    func frontLocationForPosition(var frontViewPosition:NSInteger)->CGFloat
    {
        var DSWidth:CGFloat = 0.0
        var DSOverDraw: CGFloat = 0.0
        var location :CGFloat = 0.0
        let symetry = frontViewPosition < FrontViewPosition.FrontViewPositionLeft.rawValue ? -1 : 1
        _c._getDSWidth(&DSWidth, DSOverDraw: &DSOverDraw, forSymetry: symetry)
        _c._getAdjustedFrontViewPosition(&frontViewPosition, forSymetry: symetry)
        
        if(frontViewPosition == FrontViewPosition.FrontViewPositionRight.rawValue)
        {
            location = DSWidth
        }
        
        if(frontViewPosition > FrontViewPosition.FrontViewPositionRight.rawValue)
        {
            location = DSWidth + DSOverDraw
        }
        
       // print("location +  \(location)")
        return location * CGFloat(symetry);
    }
    
    // MARK: - private
    
    func _layoutRearViewsForLocation(xLocation: CGFloat)
    {
        let bounds: CGRect = self.bounds
        var rearDSWidth = _c._rearViewSideWidth
        
        if(rearDSWidth < 0)
        {
            rearDSWidth = bounds.size.width + _c._rearViewSideWidth
        }
        
        let rearXLocation = scaled.Value(xLocation, min2: -_c._rearViewSideDisplacement, max2: 0, min1: 0, max1: rearDSWidth)
        let rearWidth:CGFloat = rearDSWidth + _c._rearViewSideOverdraw
        
        _rearView?.frame = CGRectMake(rearXLocation, 0.0, rearWidth, bounds.size.height)
        var rightDSWidth:CGFloat = _c._rightViewSideWidth
        
        if ( rightDSWidth < 0){ rightDSWidth = bounds.size.width + _c._rightViewSideWidth}
        
        let rightXLocation:CGFloat = scaled.Value(xLocation, min2: 0, max2: _c._rightViewSideDisplacement, min1: -rightDSWidth, max1: 0)
        
        let rightWidth:CGFloat = rightDSWidth + _c._rightViewSideOverdraw;
        _rightView?.frame = CGRectMake(bounds.size.width-rightWidth+rightXLocation, 0.0, rightWidth, bounds.size.height);
        
    }
    
    func _prepareForNewPosition(newPosition:NSInteger)
    {
        if ( _rearView == nil || _rightView == nil ){
            return
        }
        
        
        let symetry = newPosition < FrontViewPosition.FrontViewPositionLeft.rawValue ? -1 : 1;
        
        let subViews: NSArray = self.subviews;
        let rearIndex: NSInteger = subViews.indexOfObjectIdenticalTo(_rearView!)
        let rightIndex: NSInteger = subViews.indexOfObjectIdenticalTo(_rightView!)
        
        if ( (symetry < 0 && rightIndex < rearIndex) || (symetry > 0 && rearIndex < rightIndex) )
        {
            self.exchangeSubviewAtIndex(rightIndex, withSubviewAtIndex: rearIndex)
        }
        
    }
    
    
    func prepareRearViewForPosition(newPosition:NSInteger)
    {
        if(_rearView == nil)
        {
            _rearView = UIView(frame: bounds)
            _rearView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            self.insertSubview(_rearView!, belowSubview: _frontView!)
            
        }
        
        let xLocation: CGFloat = frontLocationForPosition(_c._frontViewPosition)
        _layoutRearViewsForLocation(xLocation)
        _prepareForNewPosition(newPosition)
    }
    
    
    func prepareRightViewForPosition(newPosition:NSInteger)
    {
        if ( _rightView == nil )
        {
            _rightView = UIView(frame: bounds)
            _rightView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            self.insertSubview(_rightView!, belowSubview: _frontView!)
        }
        let xLocation: CGFloat = frontLocationForPosition(_c._frontViewPosition)
        _layoutRearViewsForLocation(xLocation)
        _prepareForNewPosition(newPosition)
    }
    
    func _adjustedDragLocationForLocation(var x:CGFloat)->CGFloat{
        
        var result:CGFloat = 0.0
        
        var DSWidth:CGFloat = 0.0
        var DSOverdraw:CGFloat = 0.0
        var bounceBack:Bool = true
        var stableDrag:Bool = false
        let position = _c._frontViewPosition;
        let symetry = x < 0 ? -1 : 1;
        
        _c._getDSWidth(&DSWidth, DSOverDraw: &DSOverdraw, forSymetry: symetry)
        _c._getBounceBack(&bounceBack, pStableDrag1: &stableDrag, forSymetry: symetry)
        
        
        
        let stableTrack:Bool = !bounceBack || stableDrag || position == FrontViewPosition.FrontViewPositionRightMost.rawValue || position == FrontViewPosition.FrontViewPositionLeftSideMost.rawValue
        
        if ( stableTrack )
        {
            DSWidth = DSOverdraw+1
            DSOverdraw = 0.0
        }
        
        x = x * CGFloat(symetry)
        
        if (x <= DSWidth){
            result = x
        }// Translate linearly.
        else if (x <= DSWidth+2*DSOverdraw)
        {
            result = DSWidth + (x-DSWidth)/2
        }// slow down translation by halph the movement.
        else
        {
            result = DSWidth+DSOverdraw
        }
        // keep at the rightMost location.
        
        return result * CGFloat(symetry);
        
        
    }
    
    
    
    
    func dragFrontViewToXLocation(var xLocation: CGFloat)
    {
        let bounds:CGRect = self.bounds;
        
        xLocation = _adjustedDragLocationForLocation(xLocation)
        _layoutRearViewsForLocation(xLocation)
        
        let frame:CGRect = CGRectMake(xLocation, 0.0, bounds.size.width, bounds.size.height)
        _frontView!.frame = hierarchycalFrameAdjustment(frame)
    }
    
    
    
    
    
    // MARK: - overrides
    
    override func layoutSubviews()
    {
        if (disableLayout == nil )
        {
            return
        }
        let bounds:CGRect = self.bounds;
        let position = _c._frontViewPosition;
        let xLocation:CGFloat = frontLocationForPosition(position)
        // set rear view frames
        _layoutRearViewsForLocation(xLocation)
        
        let frame:CGRect = CGRectMake(xLocation, 0.0, bounds.size.width, bounds.size.height);
        _frontView!.frame = hierarchycalFrameAdjustment(frame)
        
        
        // setup front view shadow path if needed (front view loaded and not removed)
        
        let frontViewController:UIViewController? = _c._frontViewController
        let viewLoaded:Bool = (frontViewController != nil) && frontViewController!.isViewLoaded()
        
        
        let viewNotRemoved: Bool = position > FrontViewPosition.FrontViewPositionLeftSideMostRemoved.rawValue && position < FrontViewPosition.FrontViewPositionRightMostRemoved.rawValue;
        let shadowBounds:CGRect = viewLoaded && viewNotRemoved  ? _frontView!.bounds : CGRectZero;
        
        
        let shadowPath:UIBezierPath = UIBezierPath(rect: shadowBounds)
        _frontView!.layer.shadowPath = shadowPath.CGPath;
        
    }
    
    func pointInsideD(point:CGPoint, withEvent event: UIEvent)->Bool
    {
        
        var isInside:Bool = super.pointInside(point, withEvent: event)
        
        if ( _c._extendsPointInsideHit )
        {
            if ( (!isInside  && _rearView != nil) && _c._rearViewController!.isViewLoaded() )
            {
                
                let pt: CGPoint = self.convertPoint(point, toView: _rearView)
                isInside = _rearView!.pointInside(pt, withEvent: event)
            }
            
            if ( (!isInside && _frontView != nil) && _c._frontViewController!.isViewLoaded() )
            {
                let pt:CGPoint = self.convertPoint(point, toView: _frontView)
                isInside = _frontView!.pointInside(pt, withEvent: event)
            }
            
            if ( (!isInside && _rightView != nil) && _c._rightViewController!.isViewLoaded() )
            {
                let pt:CGPoint = self.convertPoint(point, toView: _rightView)
                isInside = _rightView!.pointInside(pt, withEvent: event)
            }
        }
        return isInside;
    }
    
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool
    {
        var isInside:Bool = super.pointInside(point, withEvent: event)
        
        if ( !isInside && _c._extendsPointInsideHit )
        {
            let testViews : [UIView?] = [ _rearView, _frontView, _rightView ]
            let testControllers :NSArray = [ _c._rearViewController!, _c._frontViewController!, _c._rightViewController! ]
            
            
            for ( var i=0 ; i<3 && !isInside ; i++ )
            {
                if ( (testViews[i] != nil) && testControllers[i].isViewLoaded() )
                {
                    let pt:CGPoint = self.convertPoint(point, toView: testViews[i] as UIView!)
                    isInside = testViews[i]!.pointInside(pt, withEvent: event)
                }
            }
        }
        return isInside;
        
    }
    
    
}
typealias FooCompletionHandler = () -> Void

//MARK: - SWContextTransitioningObject

class DSContextTransitionObject: NSObject,UIViewControllerContextTransitioning
{
    weak var _DSVC:DSSideViewController!
    var _view:UIView!
    var _toVC: UIViewController!
    var _fromVC: UIViewController!
    var _completionHandler: FooCompletionHandler!
    
    
    init(DSVC:DSSideViewController,containerView view:UIView ,fromVC VC:UIViewController, toVC VC1:UIViewController,completion comp:FooCompletionHandler) {
        super.init()
        _DSVC=DSVC
        _view=view
        _fromVC=VC
        _toVC=VC1
        _completionHandler=comp
    }
    
    func containerView()->UIView?
    {
        return _view
    }
    
    func isAnimated() -> Bool
    {
        return true
    }
    
    func isInteractive() -> Bool {
        return false
    }
    
    func transitionWasCancelled() -> Bool
    {
        return false
    }
    
    func presentationStyle() -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat)
    {
        
    }
    func finishInteractiveTransition()
    {
        
    }
    func cancelInteractiveTransition()
    {
        
    }
    
    func completeTransition(didComplete: Bool)
    {
        _completionHandler();
    }
    
    func viewControllerForKey(key: String) -> UIViewController?{
        
        if(key==UITransitionContextFromViewControllerKey)
        {
            return _fromVC
        }
        if (key==UITransitionContextToViewControllerKey){
            return _toVC
        }
        
        return nil;
    }
    
    func viewForKey(key: String) -> UIView?{
        return nil;
    }
    
    func initialFrameForViewController(vc: UIViewController) -> CGRect{
        return _view.bounds;
    }
    
    func finalFrameForViewController(vc: UIViewController) -> CGRect{
        return _view.bounds
    }
    func targetTransform() -> CGAffineTransform
    {
        return CGAffineTransformIdentity
    }
    
}


//MARK: - SWDefaultAnimationController Class

class SWDefaultAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
    var _duration:NSTimeInterval!
    
    init(duration:NSTimeInterval) {
        super.init()
        _duration=duration
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return _duration
    }
   
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController:UIViewController? = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        
        if (fromViewController != nil)
        {
            UIView.transitionFromView(fromViewController!.view, toView: toViewController.view, duration: _duration, options:[UIViewAnimationOptions.TransitionCrossDissolve,UIViewAnimationOptions.OverrideInheritedOptions], completion: {(finish)
                in transitionContext.completeTransition(finish)
            })
            
        }
        else
        {
            let toView:UIView = toViewController.view
            let alpha:CGFloat = toView.alpha
            
            toView.alpha = 0;
            
            UIView.animateWithDuration(_duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                toView.alpha = alpha
                }, completion: {(finish) in transitionContext.completeTransition(finish)
                    
            })
            
        }
    }
    
}

//MARK: - DSSideViewControllerPanGestureRecognizer

import UIKit.UIGestureRecognizerSubclass

class DSSideViewControllerPanGestureRecognizer: UIPanGestureRecognizer {
    var _dragging:Bool = false
    var _beginPoint:CGPoint!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let touch:UITouch = touches.first as UITouch!
        _beginPoint = touch.locationInView(self.view)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if ( _dragging || self.state == UIGestureRecognizerState.Failed){
            return
        }
        let kDirectionPanThreshold:Int = 5;
        let touch:UITouch = touches.first as UITouch!
        let nowPoint:CGPoint = touch.locationInView(self.view)
        if (abs(nowPoint.x - _beginPoint.x) > CGFloat(kDirectionPanThreshold)){
            _dragging = true
        }
        else if (abs(nowPoint.y - _beginPoint.y) > CGFloat(kDirectionPanThreshold)){
            self.state = UIGestureRecognizerState.Failed;
        }
    }
}




enum FrontViewPosition: NSInteger {
    
    case FrontViewPositionNone = 255
    case FrontViewPositionLeftSideMostRemoved = 0
    case FrontViewPositionLeftSideMost = 1
    case FrontViewPositionLeftSide = 2
    case FrontViewPositionLeft = 3
    case FrontViewPositionRight = 4
    case FrontViewPositionRightMost = 5
    case FrontViewPositionRightMostRemoved = 6
    
}

enum SWDSToggleAnimationType: NSInteger {
    case SWDSToggleAnimationTypeSpring    // <- produces a spring based animation
    case SWDSToggleAnimationTypeEaseOut   // <- produces an ease out curve animation
}

enum DSSideControllerOperation {
    case DSSideControllerOperationNone
    case DSSideControllerOperationReplaceRearController
    case DSSideControllerOperationReplaceFrontController
    case DSSideControllerOperationReplaceRightController
    
}

protocol DSSideViewControllerDelegate: NSObjectProtocol
{
    
    func DSController(DSController:DSSideViewController,willMoveToPosition position:NSInteger)
    
    func DSController(DSController:DSSideViewController,didMoveToPosition position:NSInteger)
    
    func DSController(DSController:DSSideViewController,animateToPosition position:NSInteger)
    
    func DSControllerPanGestureShouldBegin(DSController:DSSideViewController)->Bool
    
    func DSControllerTapGestureShouldBegin(DSController:DSSideViewController)->Bool
    
    func DSController(DSController:DSSideViewController, panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer:UIGestureRecognizer)->Bool

    func DSController(DSController:DSSideViewController, tapGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer:UIGestureRecognizer)->Bool

    func DSControllerPanGestureBegan(DSController:DSSideViewController)
    
    func DSControllerPanGestureEnded(DSController:DSSideViewController)
    
    func DSController(DSController:DSSideViewController,panGestureBeganFromLocation location:CGFloat,progress1 progress:CGFloat,overProgress1 overProgress:CGFloat)
    
    func DSController(DSController:DSSideViewController,panGestureMovedToLocation location:CGFloat,progress1 progress:CGFloat,overProgress1 overProgress:CGFloat)
    
    func DSController(DSController:DSSideViewController,panGestureEndedToLocation location:CGFloat,progress1 progress:CGFloat,overProgress1 overProgress:CGFloat)
    
    func DSController(DSController:DSSideViewController, willAddViewController viewController:UIViewController, forOperation operation:DSSideControllerOperation, animated1 animated:Bool)
    
    func DSController(DSController:DSSideViewController, didAddViewController viewController:UIViewController, forOperation operation:DSSideControllerOperation, animated1 animated:Bool)

    func DSController(DSController:DSSideViewController,forOperation operation:DSSideControllerOperation,fromViewController fromVC:UIViewController,toViewController toVC:UIViewController) ->UIViewControllerAnimatedTransitioning
    
}

//MARK: - UIViewController(DSSideViewController) Category
extension UIViewController
{
    func DSViewController()-> DSSideViewController? {
        return sideMenuControllerForViewController(self)
    }
    
    private func sideMenuControllerForViewController(controller : UIViewController) -> DSSideViewController?
    {
        if let sideController = controller as? DSSideViewController {
            return sideController
        }
        
        if controller.parentViewController != nil {
            return sideMenuControllerForViewController(controller.parentViewController!)
        }else{
            return nil
        }
    }
}


extension Float {
    var fvalue: CGFloat { return CGFloat(self) }
}

extension Double{
    var cfValue: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat {
    var swf: Float { return Float(self) }
    var dvalue: Double { return Double(self) }
}

// MARK: - DSSideViewControllerSegueSetController segue identifiers

// MARK: - DSSideViewControllerSegueSetController class

@objc(DSSideViewControllerSegueSetController)
class DSSideViewControllerSegueSetController: UIStoryboardSegue {
    
    override func perform() {
        
        
        var operation: DSSideControllerOperation = DSSideControllerOperation.DSSideControllerOperationNone
        let identifier: NSString? = self.identifier;
        let rvc: DSSideViewController = self.sourceViewController as! DSSideViewController
        let dvc:UIViewController! = self.destinationViewController
        
        if identifier == DSSegueFrontIdentifier{
            operation = DSSideControllerOperation.DSSideControllerOperationReplaceFrontController
        }
        else if identifier == DSSegueRearIdentifier{
            operation = DSSideControllerOperation.DSSideControllerOperationReplaceRearController
        }
        else if identifier == DSSegueRightIdentifier{
            operation = DSSideControllerOperation.DSSideControllerOperationReplaceRightController
        }
        
        if(operation != DSSideControllerOperation.DSSideControllerOperationNone)
        {
            rvc._performTransitionOperation(operation, withViewController:dvc!, animated1: false)
        }
        
        
    }

}

// MARK: - DSSideViewControllerSeguePushController class
@objc(DSSideViewControllerSeguePushController)
class DSSideViewControllerSeguePushController:UIStoryboardSegue {
    
    
    func perfrom()
    {
        
        let rvc:DSSideViewController = self.sourceViewController.DSViewController()!
        let dvc:UIViewController? = self.destinationViewController
        rvc.pushFrontViewController(dvc!, animated: true)
    }
}


