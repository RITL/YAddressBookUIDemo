//
//  YContactsTableViewController.m
//  YAddressBookDemo
//
//  Created by YueWen on 16/5/9.
//  Copyright © 2016年 YueWen. All rights reserved.
//

#import "YContactsTableViewController.h"
#import "YContactsManager.h"
#import "YContactObject.h"

@import AddressBookUI;


static NSString * const reuseIdentifier = @"RightCell";


@interface YContactsTableViewController ()<ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,ABUnknownPersonViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, copy)NSArray <YContactObject *> *  contactObjects;

@property (nonatomic, strong) YContactsManager * contactManager;
@end

@implementation YContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contactManager = [YContactsManager shareInstance];
    
    //开始请求
    [self requestContacts];

}


//开始请求所有的联系人
- (void)requestContacts
{
    __weak typeof(self) copy_self = self;
    
    //开始请求
    [self.contactManager requestContactsComplete:^(NSArray<YContactObject *> * _Nonnull contacts) {
        
        //开始赋值
        copy_self.contactObjects = contacts;
        
        //刷新
        [copy_self.tableView reloadData];
        
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.contactObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //fetch Model
    YContactObject * contactObject = [self.contactObjects objectAtIndex:indexPath.row];
    
    //configture cell..
    cell.textLabel.text = contactObject.nameObject.name;
    cell.detailTextLabel.text = contactObject.phoneObject.firstObject.phoneNumber;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //select cell coding...
    
    //选中的Model
    YContactObject * contactObject = self.contactObjects[indexPath.row];

    //进入详细修改界面
    ABPersonViewController * personViewController = [[ABPersonViewController alloc]init];

    //对显示的Person值进行赋值,因为这里是自己构建的Model,所以需要对结构体进行NSValue转型
    personViewController.displayedPerson = CFBridgingRetain([(NSValue *)[contactObject valueForKey:@"recordRefValue"] pointerValue]);

    //不允许联系人编辑，此时右上角的Edit按钮也就不会出现,默认为true
    //personViewController.allowsEditing = false;

    //不允许最下面出现发送信息以及共享联系人的选项，默认为true
    //personViewController.allowsActions = false;

    //允许显示链接联系人，默认为false
    personViewController.shouldShowLinkedPeople = true;

    //设置代理
    personViewController.personViewDelegate = self;

    [self.navigationController pushViewController:personViewController animated:true];
    
    
}


#pragma mark - Target Action

//进入新建联系人控制器
- (IBAction)pushToNewPersonViewController:(id)sender
{

//    //初始化添加联系人的控制器
//    ABNewPersonViewController * newPersonViewController = [[ABNewPersonViewController alloc]init];
//    
//    //设置代理
//    newPersonViewController.newPersonViewDelegate = self;
//    
//    UINavigationController * navigationViewController = [[UINavigationController alloc]initWithRootViewController:newPersonViewController];
//
//    //present..
//    [self presentViewController:navigationViewController animated:true completion:^{
//        
//    }];
    
    //实例化一个person
    ABRecordRef person = ABPersonCreate();

    //设置姓名
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)@"firstName", NULL);


    //初始化未知联系人的控制器
    ABUnknownPersonViewController * unknowPersonViewController = [[ABUnknownPersonViewController alloc]init];

    //设置代理
    unknowPersonViewController.unknownPersonViewDelegate = self;

    //设置相关属性
    unknowPersonViewController.alternateName = @"alternateName";//替代名和姓的替代符
    unknowPersonViewController.displayedPerson = person;        //展示的person对象
    unknowPersonViewController.message = @"message";            //存在替代符下面的信息
    unknowPersonViewController.allowsActions = true;            //是否允许作用(出现共享联系人等)
    unknowPersonViewController.allowsAddingToAddressBook = true;//是否允许添加到通讯录(新建或添加到现有联系人)

    //释放资源
    CFRelease(person);

    //push..
    [self.navigationController pushViewController:unknowPersonViewController animated:true];
 
}


/**
 *  模态跳到选择联系人控制器
 */
- (IBAction)pushPickerPersonViewController:(id)sender
{ 
    //初始化
    ABPeoplePickerNavigationController * peoplePickerNavigationController = [[ABPeoplePickerNavigationController alloc]init];
    
    //设置相关属性
    peoplePickerNavigationController.peoplePickerDelegate = self;
    
    
    [self presentViewController:peoplePickerNavigationController animated:true completion:^{}];
    
}




#pragma mark - <ABNewPersonViewControllerDelegate>

/**
 *  新增联系人点击Cancel或者Done之后的回调方法
 *
 *  @param newPersonView 调用该方法的ABNewPersonViewController对象
 *  @param person        传出的ABRecordRef属性
 *                       点击了Done,person就是新增的联系人属性
 *                       点击了Cancel,person就是NULL
 */
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person
{
    //表示取消了
    if (person == NULL)
    {
       //Cancle coding..
    }
    
    //表示保存成功
    else
    {
       //Cancle Done..
    [self requestContacts];
    }
    
    //不管成功与否，都需要跳回
    [newPersonView dismissViewControllerAnimated:true completion:^{
        
    }];
}



#pragma mark - <ABPersonViewControllerDelegate>

/**
 *  根据页面选择的属性进行响应判断
 *
 *  @param personViewController 进行回调的ABPersonViewController对象
 *  @param person               展示的Person属性
 *  @param property             进行响应的属性Key
 *  @param identifier           如果是多值属性，返回多值属性
 *
 *  @return 是否响应，true为按照系统的方式响应，false为不响应
 */
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifier
{
    //如果点击的是电话选项，不进行响应，也就是在真机中，再点击电话哪一行的cell,就打不出电话了
    if (property == kABPersonPhoneProperty)
    {
        return false;
    }

    return true;
}


#pragma mark - <ABUnknownPersonViewControllerDelegate>

/**
 *  当创建新的联系人或者更新到以存在的联系人时调用的方法
 *
 *  @param unknownCardViewController 调用方法的ABUnknownPersonViewController对象
 *  @param person                    创建或者更新的ABRecordRef属性
 */
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController
                 didResolveToPerson:(nullable ABRecordRef)person
{
    //需要返回原本控制器
    [unknownCardViewController.navigationController popViewControllerAnimated:true];
}


- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController
shouldPerformDefaultActionForPerson:(ABRecordRef)person
                           property:(ABPropertyID)property
                         identifier:(ABMultiValueIdentifier)identifier
{
    return true;
}


#pragma mark - <ABPeoplePickerNavigationControllerDelegate>
/**
 *  点击Cancle进行的回调
 *
 *  @param peoplePicker 进行回调的ABPeoplePickerNavigationController
 */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    //模态弹回
    [peoplePicker dismissViewControllerAnimated:true completion:^{}];
}


/**
 *  选择了联系人之后进行何种操作的回调(iOS8.0之后由下面的方法替代)
 *
 *  @param peoplePicker 进行回调的ABPeoplePickerNavigationController对象
 *  @param person       选择的Person
 *
 *  @return true表示能够显示通讯录并dismiss掉选择器，false表示不做任何事
 */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person NS_DEPRECATED_IOS(2_0, 8_0)
{
    return false;
}

/**
 *  选择了联系人之后进行的回调(替代上面协议方法的方法，在iOS8.0之后可用)
 *
 *  或者用属性predicateForSelectionOfPerson来替代
 *
 *  @param peoplePicker 进行回调的ABPeoplePickerNavigationController对象
 *  @param person       选择的Person
 */
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    //coding record the person
    
    //dismiss掉选择器
    [peoplePicker dismissViewControllerAnimated:true completion:^{}];
    
}



/**
 *  选择了联系人之后选择属性时进行何种操作的回调(iOS8.0之后用下面的方法替代)
 *
 * (peoplePickerNavigationController:shouldContinueAfterSelectingPerson: 的详细版)
 *
 *  @param peoplePicker 进行回调的ABPeoplePickerNavigationController对象
 *  @param person       选择的person对象
 *  @param property     选择的属性
 *  @param identifier   如果是多值，传出多值属性，单值属性时可以忽略
 *
 *  @return true表示进行系统的默认操作并dismiss出选择器，false表示在当前选择器显示该联系人
 */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier NS_DEPRECATED_IOS(2_0,8_0)
{
    return false;
}




/**
 *  选择了联系人之后选择属性时进行何种操作的回调(替代上面协议方法的方法，在iOS8.0之后可用)
 *
 *  或者用属性predicateForSelectionOfProperty来替代
 *
 *  @param peoplePicker 进行回调的ABPeoplePickerNavigationController对象
 *  @param person       选择的person对象
 *  @param property     选择的属性
 *  @param identifier   如果是多值，传出多值属性，单值属性时可以忽略
 */
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    //跳回
    [peoplePicker dismissViewControllerAnimated:true completion:^{}];
}






@end
