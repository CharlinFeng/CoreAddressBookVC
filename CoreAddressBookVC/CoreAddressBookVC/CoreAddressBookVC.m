#import "CoreAddressBookVC.h"
#import "JXAddressBook.h"

@interface CoreAddressBookVC ()<UIActionSheetDelegate>
{
    UITableView *_tableView;

    UISearchBar *_searchBar;
    UISearchDisplayController *_searchController;

    NSArray *_dataArray;
    NSArray *_searchArray;
}

@property (nonatomic,weak) JXPersonInfo *selectedPersonInfo;

@property (nonatomic,assign) BOOL isShowErrorMsg;

@property (nonatomic,assign) BOOL canReadAddressBook;


@end

@implementation CoreAddressBookVC

#pragma mark -
#pragma mark - Method Demo

- (void)refreshPersonInfoTableView
{
    [JXAddressBook getPersonInfo:^(NSArray *personInfos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 对获取数据进行排序
            _dataArray = [JXAddressBook sortPersonInfos:personInfos];
            [_tableView reloadData];
            _tableView.tableHeaderView = _searchBar;
        });
    }];
}
- (void)refreshSearchTableView:(NSString *)searchText
{
    [JXAddressBook searchPersonInfo:searchText addressBookBlock:^(NSArray *personInfos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 直接获取数据
            _searchArray = personInfos;
            [_searchController.searchResultsTableView reloadData];
        });
    }];
}

#pragma mark -
#pragma mark - CREATE UI

- (void)refreshAddressBook:(id)sender
{
    [self refreshPersonInfoTableView];
}

- (void)createTableView
{
    _dataArray = [NSArray array];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|
                                  UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}
- (void)createSearchBar{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _searchBar.frame.size.height)];
    _tableView.tableHeaderView = _searchBar;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索联系人";
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsTitle = @"搜索结果";
}

#pragma mark -
#pragma mark - 生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //基本配置
    [self basicPrepare];
    
    if(!self.canReadAddressBook) return;
    
    [self createTableView];
    [self createSearchBar];
    [self refreshPersonInfoTableView];
}

/** 基本配置 */
-(void)basicPrepare{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"通讯录";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    if(!self.canReadAddressBook) return;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAddressBook:)];
}



-(void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    if(self.canReadAddressBook) return;
    
    if(self.isShowErrorMsg) return;
    
    [self showMsgLabel];
    
    self.isShowErrorMsg = YES;
}



-(void)showMsgLabel{
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    
    NSMutableAttributedString *strA = [[NSMutableAttributedString alloc] initWithString:@"通讯录禁止访问\n\n\n\n 请打开“设置”-“隐私”-“通讯录”允许程序访问"];
    
    [strA addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, 7)];
    
    msgLabel.attributedText = strA;
    
    msgLabel.backgroundColor = [UIColor whiteColor];
    
    msgLabel.textAlignment = NSTextAlignmentCenter;
    
    msgLabel.numberOfLines=0;
    
    [self.view addSubview:msgLabel];
}



-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==_searchController.searchResultsTableView) {
        return 1;
    }
    return _dataArray.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView==_searchController.searchResultsTableView) {
        return @"";
    }
    return [JXSpellFromIndex(section) uppercaseString];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_searchController.searchResultsTableView) {
        return _searchArray.count;
    }
    return ((NSArray *)[_dataArray objectAtIndex:section]).count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"UITableViewCell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
    }
    
    JXPersonInfo *personInfo = nil;
    
    if (tableView == _searchController.searchResultsTableView) {
        personInfo = [_searchArray objectAtIndex:indexPath.row];
    }else {
        NSArray *subArr = [_dataArray objectAtIndex:indexPath.section];
        personInfo = [subArr objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = personInfo.fullName;

    cell.detailTextLabel.text = personInfo.showAllPhoneNO;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    JXPersonInfo *personInfo = nil;
    if (tableView==_searchController.searchResultsTableView) {
        personInfo = [_searchArray objectAtIndex:indexPath.row];
    }else {
        personInfo = [[_dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if(personInfo.phone.count<=1){ //单个或无联系人
       
        if(personInfo.phone.count != 0) personInfo.selectedPhoneNO = ((NSDictionary *)personInfo.phone.firstObject).allValues.firstObject;

        [self selectedPerson:personInfo];
        
    }else{ //多个联系人
        
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@" 【 %@ 】 共有%@个号码，请选择其中的1个号码",personInfo.fullName,@(personInfo.phone.count)] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        
        NSArray *otherButtonTitles=[personInfo.showAllPhoneNO componentsSeparatedByString:@","];
        
        //添加其他标题
        if(otherButtonTitles!=nil && otherButtonTitles.count!=0){
            for (NSString *otherButtonTitle in otherButtonTitles) {
                [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@", otherButtonTitle]];
            }
        }
        
        sheet.delegate = self;
        
        [sheet showInView:self.view.window];
        
        self.selectedPersonInfo = personInfo;
    }
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(buttonIndex != 0){
        
        self.selectedPersonInfo.selectedPhoneNO = [self.selectedPersonInfo.phone[buttonIndex - 1] allValues].firstObject;
        
        [self selectedPerson:self.selectedPersonInfo];
        
    }
    
    
    /** 清空 */
    self.selectedPersonInfo = nil;
}





-(void)selectedPerson:(JXPersonInfo *)personInfo{
    
    if(self.delegate == nil) return;
    
    if(![self.delegate respondsToSelector:@selector(addressBookVCSelectedContact:)]) return;
    
    [self.delegate addressBookVCSelectedContact:personInfo];
    
    [self dismiss];
}


-(void)dealloc{
    self.delegate = nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==_searchController.searchResultsTableView) {
        return 0;
    }
    
    if (((NSArray *)[_dataArray objectAtIndex:section]).count==0) {
        return 0;
    }
    return 30;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView==_searchController.searchResultsTableView) {
        return @[];
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 27; i++) {
        [arr addObject:[JXSpellFromIndex(i) uppercaseString]];
    }
    return arr;
}

#pragma mark -
#pragma mark - SearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self refreshSearchTableView:searchText];
}

-(BOOL)canReadAddressBook{
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    return status != kABAuthorizationStatusDenied;
}


@end
