import 'dart:ui';
import 'package:easy_localization/easy_localization.dart' show AssetLoader;
class CodegenLoader extends AssetLoader {
const CodegenLoader();
@override
Future<Map<String, dynamic>> load(String fullPath, Locale locale) {
  return Future.value(mapLocales[locale.toString()]);
}
static const Map<String, dynamic>  en_US = {
  'appTitle' : 'HSEASSIST',
  'addUser' : ' Add User',
  'admin' : ' Admin',
  'allDone' : ' All Done',
  'approve' : ' pprove',
  'cancel' : ' Cancel',
  'chatDefaultMessage' : ' Type a message',
  'code' : ' Code',
  'confirmPassword' : ' Confirm Password',
  'darkMode' : ' Dark Mode',
  'description' : ' Description',
  'displayName' : ' Display Name',
  'displayNameLocal' : ' Display Name Local',
  'email' : ' Email',
  'empty' : ' empty value',
  'englishInterface' : ' English Interface',
  'errorOccured' : ' Error Occured',
  'firstName' : ' First Name',
  'forgotPassword' : ' Forgot Password',
  'geminiTypeMessage' : ' Type a message',
  'home' : ' Home',
  'invalid' : ' invalid value',
  'invitaionCode' : ' Invitaion Code',
  'invitationRecievedMessage' : ' Invitation Recieved',
  'inviteUser' : ' Invite User',
  'isGroupManager' : ' Is Group Manager',
  'isNewOrganization' : ' Is New Organization',
  'itemNo' : ' Item No',
  'joinOrganization' : ' Join Organization',
  'language' : ' Language',
  'lastName' : ' Last Name',
  'lightMode' : ' Light Mode',
  'loadingError' : ' Loading Error Please try again',
  'login' : ' Login',
  'logout' : ' Logout',
  'mismatch' : ' mismatch error',
  'moreInfo' : ' More Info',
  'name' : ' Name',
  'newPassword' : ' New Password',
  'newPasswordMessage' : ' Please enter a new password',
  'noAccount' : ' Don\'t have an account?',
  'noItems' : ' NoItems',
  'notes' : ' Notes',
  'notifications' : ' Notifications',
  'ok' : ' Ok',
  'organization' : ' Organization',
  'organizationInvitaionMessage' : ' You have an invitation to join',
  'password' : ' Password',
  'phone' : ' Phone',
  'profile' : ' Profile',
  'register' : ' Register',
  'registerSuccess' : ' Success please login',
  'reject' : ' Reject',
  'remember' : ' Remember',
  'rememberMe' : ' Remember Me',
  'resetPassword' : ' Reset Password',
  'role' : ' Role',
  'save' : ' Save',
  'search' : ' Search',
  'settings' : ' Settings',
  'signUp' : ' Sign Up',
  'success' : ' Success',
  'successCheckMail' : ' Successplease check your email.',
  'thereAreRisks' : ' There are Risks',
  'type' : ' Type',
  'user' : ' User',
  'userInformation' : ' User Information',
  'username' : ' Username',
  'validator_errors.addressEmpty' : ' Address is required',
  'validator_errors.emailEmpty' : ' Email is required',
  'validator_errors.emailinvalid' : ' Please enter a valid email',
  'validator_errors.nameEmpty' : ' Name is required',
  'validator_errors.passwordConfirmEmpty' : ' Confirm password is required',
  'validator_errors.passwordConfirmNoMatch' : ' Confirm password does not match',
  'validator_errors.passwordEmpty' : ' Password is required',
  'validator_errors.passwordInvalid' : ' Password must be at least 6 characters',
  'welcome' : ' Welcome',
  'workgroup' : ' Workgroup',
  'workgroupDivision' : ' Workgroup Division',
  'workgroupLocation' : ' Workgroup Location',
  'workgroupSubDivision' : ' Workgroup Sub Division',
};
static const Map<String, dynamic>  ar_EG = {
  'appTitle' : 'مساعد الامان',
  'addUser' : ' ضف مستخدم',
  'admin' : ' المدير',
  'allDone' : ' الكل انتهي',
  'approve' : ' قبول',
  'cancel' : ' إلغاء',
  'chatDefaultMessage' : ' ادخل تساؤل',
  'code' : ' رمز',
  'confirmPassword' : ' تأكيد كلمة المرور',
  'darkMode' : ' واجهة داكنة',
  'description' : ' وصف',
  'displayName' : ' اسم المستخدم',
  'displayNameLocal' : ' الاسم باللغة المحلية ',
  'email' : ' بريد إلكتروني',
  'empty' : ' قيمة فارغة',
  'englishInterface' : ' الواجهة بالإنجليزية',
  'errorOccured' : ' حدوث خطأ',
  'firstName' : ' الإسم الاول',
  'forgotPassword' : ' نسيت كلمة المرور',
  'geminiTypeMessage' : ' أكتب رسالة',
  'home' : ' الرئيسي',
  'invalid' : ' قيمة غير صحيحة',
  'invitaionCode' : ' كود دعوة',
  'invitationRecievedMessage' : ' دعوة مقدمة',
  'inviteUser' : ' دعوة المستخدم',
  'isGroupManager' : ' مسؤول مجموعة',
  'isNewOrganization' : ' إنشاء منظمة جديدة',
  'itemNo' : ' رقم البند',
  'joinOrganization' : ' إنضمام إلى المنظمة',
  'language' : ' اللغة',
  'lastName' : ' الإسم الاخير',
  'lightMode' : ' واجهة فاتحة',
  'loadingError' : ' خطأ في التحميل الرجاء المحاولة',
  'login' : ' تسجيل الدخول',
  'logout' : ' تسجيل الخروج',
  'mismatch' : ' عدم مطابقة',
  'moreInfo' : ' مزيد من المعلومات',
  'name' : ' اسم',
  'newPassword' : ' كلمة السر الجديدة',
  'newPasswordMessage' : ' الرجاء إدخال كلمة السر الجديدة',
  'noAccount' : ' لا يوجد حساب',
  'noItems' : ' لا توجد نتائج',
  'notes' : ' ملاحظات',
  'notifications' : ' إشعارات',
  'ok' : ' تم',
  'organization' : ' مؤسسة',
  'organizationInvitaionMessage' : ' تم دعوتك لتنضم إلى',
  'password' : ' كلمة السر',
  'phone' : ' رقم التليفون',
  'profile' : ' ملف شخصي',
  'register' : ' سجل',
  'registerSuccess' : ' تم بنجاح الرجاء الدخول',
  'reject' : ' رفض',
  'remember' : ' تذكر',
  'rememberMe' : ' تذكرني',
  'resetPassword' : ' إعادة تعيين كلمة السر',
  'role' : ' دور',
  'save' : ' حفظ',
  'search' : ' بحث',
  'settings' : ' إعدادات',
  'signUp' : ' اشترك',
  'success' : ' تم بنجاح',
  'successCheckMail' : ' تم  الرجاء فحص البريد الإلكتروني.',
  'thereAreRisks' : ' يوجد مخاطر',
  'type' : ' نوع',
  'user' : ' مستخدم',
  'userInformation' : ' معلومات المستخدم',
  'username' : ' اسم المستخدم',
  'validator_errors.addressEmpty' : '',
  'validator_errors.emailEmpty' : '',
  'validator_errors.emailinvalid' : '',
  'validator_errors.nameEmpty' : '',
  'validator_errors.passwordConfirmEmpty' : '',
  'validator_errors.passwordConfirmNoMatch' : '',
  'validator_errors.passwordEmpty' : '',
  'validator_errors.passwordInvalid' : '',
  'welcome' : ' مرحبا',
  'workgroup' : ' مجموعة العمل',
  'workgroupDivision' : ' قسم مجموعة العمل',
  'workgroupLocation' : ' مكان مجموعة العمل',
  'workgroupSubDivision' : ' قسم فرعي لمجموعة العمل',
};
static const Map<String, Map<String, dynamic>> mapLocales = {
 "en_US" : en_US ,
 "ar_EG" : ar_EG ,
 };
}

abstract class Strings {
  static const appTitle = 'appTitle';
  static const addUser = 'addUser';
  static const admin = 'admin';
  static const allDone = 'allDone';
  static const approve = 'approve';
  static const cancel = 'cancel';
  static const chatDefaultMessage = 'chatDefaultMessage';
  static const code = 'code';
  static const confirmPassword = 'confirmPassword';
  static const darkMode = 'darkMode';
  static const description = 'description';
  static const displayName = 'displayName';
  static const displayNameLocal = 'displayNameLocal';
  static const email = 'email';
  static const empty = 'empty';
  static const englishInterface = 'englishInterface';
  static const errorOccured = 'errorOccured';
  static const firstName = 'firstName';
  static const forgotPassword = 'forgotPassword';
  static const geminiTypeMessage = 'geminiTypeMessage';
  static const home = 'home';
  static const invalid = 'invalid';
  static const invitaionCode = 'invitaionCode';
  static const invitationRecievedMessage = 'invitationRecievedMessage';
  static const inviteUser = 'inviteUser';
  static const isGroupManager = 'isGroupManager';
  static const isNewOrganization = 'isNewOrganization';
  static const itemNo = 'itemNo';
  static const joinOrganization = 'joinOrganization';
  static const language = 'language';
  static const lastName = 'lastName';
  static const lightMode = 'lightMode';
  static const loadingError = 'loadingError';
  static const login = 'login';
  static const logout = 'logout';
  static const mismatch = 'mismatch';
  static const moreInfo = 'moreInfo';
  static const name = 'name';
  static const newPassword = 'newPassword';
  static const newPasswordMessage = 'newPasswordMessage';
  static const noAccount = 'noAccount';
  static const noItems = 'noItems';
  static const notes = 'notes';
  static const notifications = 'notifications';
  static const ok = 'ok';
  static const organization = 'organization';
  static const organizationInvitaionMessage = 'organizationInvitaionMessage';
  static const password = 'password';
  static const phone = 'phone';
  static const profile = 'profile';
  static const register = 'register';
  static const registerSuccess = 'registerSuccess';
  static const reject = 'reject';
  static const remember = 'remember';
  static const rememberMe = 'rememberMe';
  static const resetPassword = 'resetPassword';
  static const role = 'role';
  static const save = 'save';
  static const search = 'search';
  static const settings = 'settings';
  static const signUp = 'signUp';
  static const success = 'success';
  static const successCheckMail = 'successCheckMail';
  static const thereAreRisks = 'thereAreRisks';
  static const type = 'type';
  static const user = 'user';
  static const userInformation = 'userInformation';
  static const username = 'username';
  static const validatorErrorsAddressEmpty = 'validator_errors.addressEmpty';
  static const validatorErrorsEmailEmpty = 'validator_errors.emailEmpty';
  static const validatorErrorsEmailinvalid = 'validator_errors.emailinvalid';
  static const validatorErrorsNameEmpty = 'validator_errors.nameEmpty';
  static const validatorErrorsPasswordConfirmEmpty = 'validator_errors.passwordConfirmEmpty';
  static const validatorErrorsPasswordConfirmNoMatch = 'validator_errors.passwordConfirmNoMatch';
  static const validatorErrorsPasswordEmpty = 'validator_errors.passwordEmpty';
  static const validatorErrorsPasswordInvalid = 'validator_errors.passwordInvalid';
  static const welcome = 'welcome';
  static const workgroup = 'workgroup';
  static const workgroupDivision = 'workgroupDivision';
  static const workgroupLocation = 'workgroupLocation';
  static const workgroupSubDivision = 'workgroupSubDivision';
}
