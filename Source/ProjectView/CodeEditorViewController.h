
#import <Foundation/Foundation.h>
#import "FileEditorDelegate.h"
#import "../Navigation/NavigatedViewController.h"
#import "../UIScrollableToolbar/UIScrollableToolbar.h"
#import "../UICodeEditorView/UICodeEditorView.h"

@interface CodeEditorViewController : NavigatedViewController <FileEditorDelegate, UITextViewDelegate>
{
	BOOL fileEdited;
	BOOL locked;
	BOOL isOnScreen;
	
	BOOL returning;
	BOOL codeEditing;
	
	UICodeEditorView* codeArea;
	NSString* currentFilePath;
	
	UIScrollableToolbar*toolbar;
}

- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

- (BOOL)saveCurrentFile;
//- (void)setFileLocked:(BOOL)locked;

- (void)indentLeftButtonSelected;
- (void)indentRightButtonSelected;
//need another button. possibly find and replace
- (void)buildButtonSelected;
- (void)keyboardButtonSelected;

- (void)lockButtonSelected;

- (NSInteger)goToLine:(NSUInteger)line offset:(NSUInteger)offset;
- (void)goToPoint:(NSUInteger)offset;

@property (nonatomic, readonly) BOOL fileEdited;
@property (nonatomic, readonly) BOOL locked;
@property (nonatomic, readonly) BOOL isOnScreen;
@property (nonatomic, retain, readonly) UICodeEditorView* codeArea;
@property (nonatomic, retain, readonly) NSString* currentFilePath;
@property (nonatomic, retain, readonly) UIScrollableToolbar* toolbar;

@end
