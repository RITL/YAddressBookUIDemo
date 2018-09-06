# YAddressBookUIDemo
使用AddressBook.framework进行手动添加联系人，使用AddressBookUI.framework系统控制器添加联系人

博文地址:[http://blog.csdn.net/runintolove/article/details/51387594](http://blog.csdn.net/runintolove/article/details/51387594)

总结一下如何修改系统的通讯录吧。
<br>
# 修改系统通讯录的方法
## 两种方法

  1. 通过`AddressBook.framework`的各种函数来完成对AddressBook的操作。
  2. 通过`AddressBookUI.framework`中提供的系统UIViewController完成对AddressBook的操作，我们只需要使用这几个控制器，传入相应的参数并实现响应的协议方法就可以完成。

## 方法看法
以上两种方法，初学者估计不会有人想用第一种，那么个人就来谈谈对这两种方法的看法:

 1. 方法比较繁琐，需要一定量的代码来完成，适合自定义UI布局来完成，相对的比较灵活。
 2. 仅需要弹出系统的控制器，传入相应的参数并实现协议方法，就可以完成对通讯录的操作，代码量较少，但UI会固定成系统通讯录的样式，用法简单但布局不灵活。

# 通过AddressBook.framework实现
## 实例化对象

实例化一个需要添加的Person属性，当然，如果是修改，那么就获取该属性喽，怎么获取可是上一篇博文介绍的呢
```Objective-C
//实例化一个Person数据
ABRecordRef person = ABPersonCreate();

//这里因为没有addressBook属性，所以需要创建一个
ABAddressBookRef addressBook = ABAddressBookCreate();

//实例化一个CFErrorRef属性,如果实例化，下面的设置为NULL即可
CFErrorRef error = NULL;
```

## 修改联系人属性的方法
```Objective-C
/**
*   新增或修改(覆盖原值的过程)ABRecordRef中某个属性的方法
*   
*   record   新增或修改属性的person实例
*   property 属性的key值，比如kABPersonFirstNameProperty..
*/
bool ABRecordSetValue(ABRecordRef record, ABPropertyID property, CFTypeRef value, CFErrorRef* error);


/**
*   删除ABRecordRef中某个属性的方法
*   
*   record   删除属性的person实例
*   property 属性的key值，比如kABPersonFirstNameProperty..
*/
bool ABRecordRemoveValue(ABRecordRef record, ABPropertyID property, CFErrorRef* error);
```

## 修改通讯录的方法
```Objective-C

//添加联系人的方法
bool ABAddressBookAddRecord(ABAddressBookRef addressBook, ABRecordRef record, CFErrorRef* error);

//删除联系人的方法
bool ABAddressBookRemoveRecord(ABAddressBookRef addressBook, ABRecordRef record, CFErrorRef* erro);
```

## 修改完毕
```Objective-C
//添加联系人
if (ABAddressBookAddRecord(addressBook, person, &error) == true)
{
    //成功就需要保存一下
    ABAddressBookSave(addressBook, &error);
}

//不要忘记了释放资源
CFRelease(person);
CFRelease(addressBook);
```

## 具体实例

### 添加联系人的姓名属性
```Objective-C

/*添加联系人姓名属性*/
ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)@"Wen", &error);       //名字
ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)@"Yue", &error);        //姓氏
ABRecordSetValue(person, kABPersonMiddleNameProperty,(__bridge CFStringRef)@"YW", &error);        //名字中的信仰名称（比如Jane·K·Frank中的K
ABRecordSetValue(person, kABPersonPrefixProperty,(__bridge CFStringRef)@"W", &error);             //名字前缀
ABRecordSetValue(person, kABPersonSuffixProperty,(__bridge CFStringRef)@"Y", &error);             //名字后缀
ABRecordSetValue(person, kABPersonNicknameProperty,(__bridge CFStringRef)@"", &error);            //名字昵称
ABRecordSetValue(person, kABPersonFirstNamePhoneticProperty,(__bridge CFStringRef)@"Wen", &error);//名字的拼音音标
ABRecordSetValue(person, kABPersonLastNamePhoneticProperty,(__bridge CFStringRef)@"Yue", &error); //姓氏的拼音音标
ABRecordSetValue(person, kABPersonMiddleNamePhoneticProperty,(__bridge CFStringRef)@"Y", &error); //英文信仰缩写字母的拼音音标

```

### 添加联系人类型属性
```
/*添加联系人类型属性*/
ABRecordSetValue(person, kABPersonKindProperty, kABPersonKindPerson, &error);      //设置为个人类型
ABRecordSetValue(person, kABPersonKindProperty, kABPersonKindOrganization, &error);//设置为公司类型

```

### 添加联系人头像属性
```Objective-C
/*添加联系人头像属性*/
ABPersonSetImageData(person, (__bridge CFDataRef)(UIImagePNGRepresentation([UIImage imageNamed:@""])),&error);//设置联系人头像
```

### 添加联系人电话信息
```Objective-C
/*添加联系人电话信息*/
//实例化一个多值属性
ABMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);

//设置相关标志位,也可以不设置，下面的方法写NULL即可
ABMultiValueIdentifier MobileIdentifier;    //手机
ABMultiValueIdentifier iPhoneIdentifier;    //iPhone
ABMultiValueIdentifier MainIdentifier;      //主要
ABMultiValueIdentifier HomeFAXIdentifier;   //家中传真
ABMultiValueIdentifier WorkFAXIdentifier;   //工作传真
ABMultiValueIdentifier OtherFAXIdentifier;  //其他传真
ABMultiValueIdentifier PagerIdentifier;     //传呼

//设置相关数值
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551211", kABPersonPhoneMobileLabel, &MobileIdentifier);    //手机
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551212", kABPersonPhoneIPhoneLabel, &iPhoneIdentifier);    //iPhone
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551213", kABPersonPhoneMainLabel, &MainIdentifier);        //主要
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551214", kABPersonPhoneHomeFAXLabel, &HomeFAXIdentifier);  //家中传真
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551215", kABPersonPhoneWorkFAXLabel, &WorkFAXIdentifier);  //工作传真
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551216", kABPersonPhoneOtherFAXLabel, &OtherFAXIdentifier);//其他传真
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551217", kABPersonPhonePagerLabel, &PagerIdentifier);      //传呼

//自定义标签
ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"55512118", (__bridge CFStringRef)@"自定义", &PagerIdentifier);//自定义标签

//添加属性
ABRecordSetValue(person, kABPersonPhoneProperty, phoneMultiValue, &error);

//释放资源
CFRelease(phoneMultiValue);
```

### 添加联系人的工作信息
```Objective-C
/*添加联系人的工作信息*/
ABRecordSetValue(person, kABPersonOrganizationProperty, (__bridge CFStringRef)@"OYue", &error);//公司(组织)名称
ABRecordSetValue(person, kABPersonDepartmentProperty, (__bridge CFStringRef)@"DYue", &error);  //部门
ABRecordSetValue(person, kABPersonJobTitleProperty, (__bridge CFStringRef)@"JYue", &error);    //职位
```

### 添加联系人的邮件信息
```Objective-C
/*添加联系人的邮件信息*/
//实例化多值属性
ABMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);

//设置相关标志位
ABMultiValueIdentifier QQIdentifier;//QQ

//进行赋值
//设置自定义的标签以及值
ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFStringRef)@"77xxxxx48@qq.com", (__bridge CFStringRef)@"QQ", &QQIdentifier);

//添加属性
ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, &error);

//释放资源
CFRelease(emailMultiValue);
```

### 添加联系人的地址信息
```Objective-C
/*添加联系人的地址信息*/
//实例化多值属性
ABMultiValueRef addressMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);

//设置相关标志位
ABMultiValueIdentifier AddressIdentifier;

//初始化字典属性
CFMutableDictionaryRef addressDictionaryRef = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, NULL);

//进行添加
CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCountryKey, (__bridge CFStringRef)@"China");      //国家
CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCityKey, (__bridge CFStringRef)@"WeiFang");       //城市
CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressStateKey, (__bridge CFStringRef)@"ShangDong");    //省(区)
CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressStreetKey, (__bridge CFStringRef)@"Street");      //街道
CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressZIPKey, (__bridge CFStringRef)@"261500");         //邮编
CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCountryCodeKey, (__bridge CFStringRef)@"ISO");    //ISO国家编码

//添加属性
ABMultiValueAddValueAndLabel(addressMultiValue, addressDictionaryRef, (__bridge CFStringRef)@"主要", &AddressIdentifier);
ABRecordSetValue(person, kABPersonAddressProperty, addressMultiValue, &error);

//释放资源
CFRelease(addressMultiValue);
```

### 添加联系人的生日信息
```Objective-C
//添加公历生日
ABRecordSetValue(person, kABPersonBirthdayProperty, (__bridge CFTypeRef)([NSDate date]), &error);
```

常用的属性如上，其他的属性在此也就不多余了，就是一堆代码的重复，但所有的用法在上面的实例中也都已经给出，只需按照方法用即可。


# 通过AddressBookUI.framwork实现

## ABNewPersonViewController(添加联系人控制器)


顾名思义，它就是用来新增加联系人的控制器，样式就是系统通讯录下的样式，如下:
<br>
<div align="center"><img src="http://img.blog.csdn.net/20160512171003781" height=500></img></div>

这里重点的介绍一下它的协议方法，感觉最管用的也就是这个协议方法`<ABNewPersonViewControllerDelegate>`:
```Objective- C
/**
 *  新增联系人点击Cancel或者Done之后的回调方法
 *
 *  @param newPersonView 调用该方法的ABNewPersonViewController对象
 *  @param person        传出的ABRecordRef属性
 *                       点击了Done,person就是新增的联系人属性
 *                       点击了Cancel,person就是NULL
 */
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView
       didCompleteWithNewPerson:(nullable ABRecordRef)person;
```

楼主程序的实例
```Objective-C
#pragma mark - <ABNewPersonViewControllerDelegate>

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person
{
    //表示取消了
    if (person == NULL){
       //Cancle coding..
    }
    
    //表示保存成功
    else{
       //Cancle Done..
       [self requestContacts];
    }
    
    //不管成功与否，都需要跳回,因为我是通过模态跳入，所以需要dismiss
    [newPersonView dismissViewControllerAnimated:true completion:^{}];
}
```

## ABUnknownPersonViewController(未知联系人的控制器)

这个控制器刚开始接触的时候，完全有点不懂它的用处，明明有了ABNewPersonViewController，怎么还需要这个，后来发现，它还是有他的作用的，这里先不给大家看图，先看一下初始化的代码:

```Objective-C
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
```

初始化代码如上，那么再来看一下效果图:
<div align="center"><img src="http://img.blog.csdn.net/20160512201721450" height="500"></img></div>


最后介绍一下他的协议方法，说实话，他的协议方法通过文档看懂了，但是用起来很奇怪，来看一下它的协议`<ABUnknownPersonViewControllerDelegate>`：
```Objective-C
/**
 *  当创建新的联系人或者更新到已存在的联系人时调用的方法
 *
 *  @param unknownCardViewController 调用方法的ABUnknownPersonViewController对象
 *  @param person                    创建或者更新的ABRecordRef属性
 */
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController
                 didResolveToPerson:(nullable ABRecordRef)person;

//根据页面选择的属性进行响应判断，与下面的ABPersonViewController协议方法相似
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController
shouldPerformDefaultActionForPerson:(ABRecordRef)person
                           property:(ABPropertyID)property
                         identifier:(ABMultiValueIdentifier)identifier；
```


## ABPersonViewController(详细信息的控制器)

这个控制器主要是用来显示联系人详细信息，不仅如此，还可以对联系人进行编辑，先上图来看看他的样式

<div align="center"><img src="http://img.blog.csdn.net/20160512190445797" height="500"></img></div>

它的的可设置属性如下:
```Objective-C
//展示详情的Person
@property(nonatomic,readwrite) ABRecordRef displayedPerson;

//是否允许编辑，如果设置为false,右上角的Edit按钮就会消失,默认为true
@property(nonatomic) BOOL allowsEditing;

//是否允许响应，如果设置为false,下面"发送信息，共享联系人"选项就会消失,默认为true
@property(nonatomic) BOOL allowsActions;

//固定展示属性的key数组，只作用于浏览时，比如只想展示姓名，如果进入编辑状态，那么还是会全部展示出来
@property(nonatomic,copy,nullable) NSArray<NSNumber*> *displayedProperties;

//是否显示链接人，默认为false
@property(nonatomic) BOOL shouldShowLinkedPeople;

//设置属性的高亮项，如果属性值是单一的，后面的多值标识符将会被忽略
- (void)setHighlightedItemForProperty:(ABPropertyID)property
                       withIdentifier:(ABMultiValueIdentifier)identifier;
```

协议方法`<ABPersonViewControllerDelegate>`
```Objective-C
/**
 *  根据页面选择的属性进行响应判断
 *
 *  @param personViewController 进行回调的ABPersonViewController对象
 *  @param person               展示的Person
 *  @param property             进行响应的属性
 *  @param identifier           如果是多值属性，返回多值属性
 *
 *  @return 是否响应，true为按照系统默认方式响应，false为不响应
 */
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifier;
```
下面是楼主的协议实例:
```Objective-C
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                  identifier:(ABMultiValueIdentifier)identifier
{
    //如果点击的是电话选项，不进行响应，就是在真机中，点击电话cell,不会相应拨打电话
    if (property == kABPersonPhoneProperty)
    {
        return false;
    }

    return true;
}
```


## ABPeoplePickerNavigationController(选择联系人的控制器)

是顾名思义的一个选择控制器，因为是导航控制器，所以这里我选择的使用模态跳，直接来看看效果图吧:

<div align="center"><img src="http://img.blog.csdn.net/20160512202812606" height="500"></img></div>

它的协议方法如下`<ABPeoplePickerNavigationControllerDelegate>`(备注:楼主用的Xcode版本号为7.3.1，并且没有下载iOS7.0的模拟环境，所以只能走iOS8.0之后的协议方法)
```Objective-C
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
```

```Objective-C
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
```

```Objective-C
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

```
