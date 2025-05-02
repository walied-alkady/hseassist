import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/blocs/login_bloc.dart';
import 'package:hseassist/blocs/validator.dart';
import 'package:hseassist/enums/form_status.dart';
import 'package:hseassist/enums/provider_type.dart';
import 'package:hseassist/models/models.dart';
import 'package:hseassist/repository/logging_reprository.dart';
import 'package:hseassist/service/authentication_service.dart';
import 'package:hseassist/service/database_service.dart';
import 'package:hseassist/service/preferences_service.dart';
import 'package:mocktail/mocktail.dart';

const mockAdminUser = AuthUser(
  id: '0',
  uid:'0',
  firstName: 'walid',
  lastName: 'alkady',
  email: 'email',
  provider: 'password'
  );

const mockAuthUsers = <AuthUser>[
  AuthUser(
     id: '0',
  uid:'0',
  firstName: 'walid',
  lastName: 'alkady',
  email: 'email',
  provider: 'password'
  ),

];

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLoggerReprository extends Mock implements LoggerReprository {}

class MockPreferencesService extends Mock implements PreferencesService {}

class MockGoRouter extends Mock implements GoRouter {}

class FunctionHoldingClassForMixin with Validator {}

void main() {
  late LoginCubit loginCubit;
  late MockAuthenticationService mockAuthService;
  late MockDatabaseService mockDbService;
  late MockLoggerReprository mockLogger;
  late MockPreferencesService mockPrefs;
  late FunctionHoldingClassForMixin validate;

  setUp(() {
    mockAuthService = MockAuthenticationService();
    mockDbService = MockDatabaseService();
    mockLogger = MockLoggerReprository();
    mockPrefs = MockPreferencesService();
    validate = FunctionHoldingClassForMixin();

    GetIt.I.registerSingleton<AuthenticationService>(mockAuthService);
    GetIt.I.registerSingleton<DatabaseService>(mockDbService);
    GetIt.I.registerSingleton<LoggerReprository>(mockLogger);
    GetIt.I.registerSingleton<PreferencesService>(mockPrefs);
    loginCubit = LoginCubit();
    registerFallbackValue(ProviderType.password);

  });

  tearDown(() {
    GetIt.I.reset();
  });


  group('LoginCubit', () {
    test('initial state is LoginFormUpdate()', () {
      expect(loginCubit.state, const LoginFormUpdate());
    });
    
    blocTest('updateEmail updates the email correctly',
      build: () => loginCubit,
      act: (bloc) => loginCubit.updateEmail('test@example.com'),
      expect: () => [loginCubit.state.copyWith(email:'test@example.com')],
    );
    
    test('updatePassword updates the password correctly', () {
      const newPassword = 'password123';
      loginCubit.updatePassword(newPassword);
      expect(loginCubit.state.password, newPassword);
    });

    test('toggleObscureText toggles obscureText correctly', () {
      expect(loginCubit.state.obscureText, true);
      loginCubit.toggleObscureText();
      expect(loginCubit.state.obscureText, false);
    });

    test('reset resets the state to initial values', () {
      loginCubit.updateEmail('test@example.com');
      loginCubit.updatePassword('password123');
      loginCubit.reset();
      expect(loginCubit.state, const LoginFormUpdate());
    });

    group('logIn tapped', () {
      test('reset resets the state to initial values', () {
        loginCubit.updateEmail('test@example.com');
        loginCubit.updatePassword('password123');
        loginCubit.reset();
        expect(loginCubit.state, const LoginFormUpdate());
      });
      group('validator', () {
        test('Email validation works', () {
          // Test that the email is present.
          // The email field should accept valid email addresses.
          // The email field should not accept invalid email addresses.
          // The email field should display an error message when an invalid email address is entered.
          // The email field should be case-insensitive.
          expect(validate.validateEmail(null),ValidatorErrors.emailEmpty.tr());
          expect(validate.validateEmail(''),ValidatorErrors.emailEmpty.tr());
          expect(validate.validateEmail('badEmailString'),ValidatorErrors.emailinvalid.tr());
          expect(validate.validateEmail('badEmailString@'),ValidatorErrors.emailinvalid.tr());
          expect(validate.validateEmail('badEmailString@gmail'),ValidatorErrors.emailinvalid.tr());
          expect(validate.validateEmail('badEmailString@gmail.com'),isNull);
        });

        test('password validation works', () {
          // Test that the password field  is present.
          // Test that the password field is masked.
          // Test that a username field may allow for alphanumeric characters.
          // Test that the password field may require only numbers or letters.
          // Make sure that the password field is present and that it is labeled correctly.
          // Test that the password field accepts input.
          // Ensure that the password field masks input so that it is not visible as plain text.
          // Confirm that the password field has the correct level of security by testing for minimum length and character type requirements.
          // Verify that the password field does not auto-fill when using a password manager.
          // Test that the password field correctly validates input when submitting the form.
          expect(validate.validatePassword(null),'validator_errors.passwordEmpty'.tr());
          expect(validate.validatePassword(''),'validator_errors.passwordEmpty'.tr());
          expect(validate.validatePassword('11'),'validator_errors.passwordInvalid'.tr());
          expect(validate.validatePassword('111111'),isNull);
        });

      });
      group('login', (){
        blocTest<LoginCubit, LoginFormUpdate>(
        'login Failure user not found in auth',
        build: () => loginCubit,
        setUp: () {
          when(() => mockAuthService.logIn(
                email: any(named: 'email'),
                password: any(named: 'password'),
                provider: any(named: 'provider'),
              )).thenAnswer((_) async {});
          // Simulate no user initially    
          when(() => mockAuthService.currentAuthUser).thenReturn(null); 
          when(() => mockAuthService.currentDbUser).thenReturn(mockAdminUser);
          when(() => mockDbService.findOne<WorkplaceInvitation>(any())).thenAnswer((_) async => null);
        },
        act: (cubit) => cubit.login(),
        expect: () => [
          const LoginFormUpdate(status: FormStatus.inProgress),
          const LoginFormUpdate(status: FormStatus.failure, errorMessage: 'No user found for that email!')
        ],
      );
        blocTest<LoginCubit, LoginFormUpdate>(
        'login success with password provider',
        build: () => loginCubit,
        setUp: () {
          when(() => mockAuthService.logIn(
                email: any(named: 'email'),
                password: any(named: 'password'),
                provider: any(named: 'provider'),
              )).thenAnswer((_) async {});
          when(() => mockAuthService.currentAuthUser).thenReturn(null); // Simulate no user initially
          when(() => mockAuthService.currentDbUser).thenReturn(mockAdminUser);
          when(() => mockDbService.findOne<WorkplaceInvitation>(any()))
              .thenAnswer((_) async => null);
        },
        act: (cubit) => cubit.login(),
        expect: () => [
          const LoginFormUpdate(status: FormStatus.inProgress),
          const LoginFormUpdate(status: FormStatus.failure, errorMessage: 'No user found for that email!')
        ],
      );
    
      });
      
    });
  });
}
