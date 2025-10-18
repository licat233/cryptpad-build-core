# CRYPTPAD 项目部署说明

## 推荐使用 build.sh 脚本一键部署
```shell
./build.sh 
```
针对 docker 安装的部署
```shell
./build.sh docker
```

### 编辑 customize/application_config.js 文件
```javascript
// 更改默认语言为中文
AppConfig.availableLanguages = ['zh', 'en']
try {
    var LS_LANG = "CRYPTPAD_LANG";
    var defaultLang = 'zh';
    if (!localStorage.getItem(LS_LANG)) {
        localStorage.setItem(LS_LANG, defaultLang);
    }
} catch (error) {
    console.error("设置默认中文语言出错：", error)
}
```
```javascript
// 修改登录盐值，增强安全性
AppConfig.loginSalt = 'licat2333'
```
```javascript
// 限制所有类型必须注册用户才能使用
AppConfig.registeredOnlyTypes = AppConfig.availablePadTypes; 
```

### 编辑 config/config.js 文件
```javascript
// 移除捐赠按钮
removeDonateButton: true 
```

```javascript
// 如果采用 docker 部署，则修改
// 监听所有地址
httpAddress: '0.0.0.0' 
// 安装方式为 docker
installMethod: 'docker' 
```

### 自定义某些样式
```javascript
// 去除 footer 捐赠按钮
// customeize.dist/pages.js: Line 151
// 将 Pages.infopageFooter 函数返回值设为 null 
Pages.infopageFooter = function () {
        return null;
}
```
```javascript
// 去除导航中的关于按钮
// customeize.dist/pages.js: Line 239
// 添加 hidden 属性
h('a.nav-item.nav-link', { href: 'https://docs.cryptpad.org',hidden:""},
```
```javascript
// 隐藏 contact 联系我们链接
// customeize.dist/pages/index.js: Line 199
// 添加 hidden 属性
h('a', {href:"/contact.html",hidden:""}, Msg.contact),
```
```javascript
// 关闭聚焦后的右下角的【我们需要您的帮助！】自动弹窗
// wwww/common/common-ui-elements.js: Line 3400
// 提前return，不执行弹窗代码
var todo = function () {
    crowdfundingState = true;
    return;
```
```javascript
// 移除关于我们菜单项
// wwww/common/common-ui-elements.js: Line  2288
// 添加 hidden 属性
attributes: {
    'class': 'cp-toolbar-about fa fa-info',
    'hidden': true,
},
```
```javascript
// 移除官方文档菜单项
// wwww/common/common-ui-elements.js: Line  2266
// 添加 hidden 属性
attributes: {
    'target': '_blank',
    'rel': 'noopener',
    'href': 'https://docs.cryptpad.org',
    'class': 'fa fa-book',
    'hidden': true,
},
```
```javascript
// 移除帮助菜单
// wwww/common/onlyoffice/inner.js: Line   3338
// 强制条件为 false 不执行添加帮助菜单节点代码
if (false&&!privateData.isEmbed) {
```