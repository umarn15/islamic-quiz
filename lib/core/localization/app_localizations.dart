import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ur'), // Urdu
  ];

  // Get current language name
  String get currentLanguage {
    switch (locale.languageCode) {
      case 'ur':
        return 'اردو';
      default:
        return 'English';
    }
  }

  // Check if current locale is RTL
  bool get isRtl => locale.languageCode == 'ur' || locale.languageCode == 'ar';

  // ============ App General ============
  String get appTitle => _translate('appTitle', 'Islamic Quiz', 'اسلامی کوئز');
  String get masterYourKnowledge => _translate('masterYourKnowledge', 'Master your knowledge', 'اپنے علم کو مضبوط کریں');

  // ============ Home Screen ============
  String get letsLearnAndHaveFun => _translate('letsLearnAndHaveFun', "Let's learn and have fun!", 'آئیں سیکھیں اور مزے کریں!');
  String get points => _translate('points', 'Points', 'پوائنٹس');
  String get pickYourChallenge => _translate('pickYourChallenge', 'Pick Your Challenge!', 'اپنا چیلنج منتخب کریں!');
  String get easy => _translate('easy', 'Easy', 'آسان');
  String get medium => _translate('medium', 'Medium', 'درمیانہ');
  String get hard => _translate('hard', 'Hard', 'مشکل');
  String get perfectForBeginners => _translate('perfectForBeginners', 'Perfect for beginners!', 'شروع کرنے والوں کے لیے بہترین!');
  String get readyForMore => _translate('readyForMore', 'Ready for more?', 'مزید کے لیے تیار؟');
  String get forTheBraveOnes => _translate('forTheBraveOnes', 'For the brave ones!', 'بہادروں کے لیے!');
  String get howManyQuestions => _translate('howManyQuestions', 'How Many Questions?', 'کتنے سوالات؟');
  String get questions => _translate('questions', 'Questions', 'سوالات');

  // ============ Greetings ============
  String get goodMorning => _translate('goodMorning', 'Good Morning', 'صبح بخیر');
  String get goodAfternoon => _translate('goodAfternoon', 'Good Afternoon', 'دوپہر بخیر');
  String get goodEvening => _translate('goodEvening', 'Good Evening', 'شام بخیر');

  // ============ Settings Screen ============
  String get settings => _translate('settings', 'Settings', 'ترتیبات');
  String get appearance => _translate('appearance', 'Appearance', 'ظاہری شکل');
  String get darkMode => _translate('darkMode', 'Dark Mode', 'ڈارک موڈ');
  String get darkThemeEnabled => _translate('darkThemeEnabled', 'Dark theme is enabled', 'ڈارک تھیم فعال ہے');
  String get lightThemeEnabled => _translate('lightThemeEnabled', 'Light theme is enabled', 'لائٹ تھیم فعال ہے');
  String get language => _translate('language', 'Language', 'زبان');
  String get selectLanguage => _translate('selectLanguage', 'Select Language', 'زبان منتخب کریں');
  String get account => _translate('account', 'Account', 'اکاؤنٹ');
  String get about => _translate('about', 'About', 'کے بارے میں');
  String get appVersion => _translate('appVersion', 'App Version', 'ایپ ورژن');
  String get signIn => _translate('signIn', 'Sign In', 'سائن ان');
  String get signOut => _translate('signOut', 'Sign Out', 'سائن آؤٹ');
  String get signInToSaveProgress => _translate('signInToSaveProgress', 'Sign in to save your progress', 'اپنی پیشرفت محفوظ کرنے کے لیے سائن ان کریں');
  String get signOutConfirmTitle => _translate('signOutConfirmTitle', 'Sign Out', 'سائن آؤٹ');
  String get signOutConfirmMessage => _translate('signOutConfirmMessage', 'Are you sure you want to sign out?', 'کیا آپ واقعی سائن آؤٹ کرنا چاہتے ہیں؟');
  String get cancel => _translate('cancel', 'Cancel', 'منسوخ');

  // ============ Auth Screens ============
  String get welcomeBack => _translate('welcomeBack', 'Welcome Back', 'خوش آمدید');
  String get signInToContinue => _translate('signInToContinue', 'Sign in to continue your journey', 'اپنا سفر جاری رکھنے کے لیے سائن ان کریں');
  String get email => _translate('email', 'Email', 'ای میل');
  String get password => _translate('password', 'Password', 'پاس ورڈ');
  String get forgotPassword => _translate('forgotPassword', 'Forgot Password?', 'پاس ورڈ بھول گئے؟');
  String get dontHaveAccount => _translate('dontHaveAccount', "Don't have an account? ", 'اکاؤنٹ نہیں ہے؟ ');
  String get signUp => _translate('signUp', 'Sign Up', 'سائن اپ');
  String get createAccount => _translate('createAccount', 'Create Account', 'اکاؤنٹ بنائیں');
  String get startYourJourney => _translate('startYourJourney', 'Start your learning journey today', 'آج ہی اپنا سیکھنے کا سفر شروع کریں');
  String get fullName => _translate('fullName', 'Full Name', 'پورا نام');
  String get confirmPassword => _translate('confirmPassword', 'Confirm Password', 'پاس ورڈ کی تصدیق');
  String get alreadyHaveAccount => _translate('alreadyHaveAccount', 'Already have an account? ', 'پہلے سے اکاؤنٹ ہے؟ ');

  // ============ Validation Messages ============
  String get pleaseEnterEmail => _translate('pleaseEnterEmail', 'Please enter your email', 'براہ کرم اپنا ای میل درج کریں');
  String get pleaseEnterValidEmail => _translate('pleaseEnterValidEmail', 'Please enter a valid email', 'براہ کرم درست ای میل درج کریں');
  String get pleaseEnterPassword => _translate('pleaseEnterPassword', 'Please enter your password', 'براہ کرم اپنا پاس ورڈ درج کریں');
  String get pleaseEnterName => _translate('pleaseEnterName', 'Please enter your name', 'براہ کرم اپنا نام درج کریں');
  String get nameTooShort => _translate('nameTooShort', 'Name must be at least 2 characters', 'نام کم از کم 2 حروف کا ہونا چاہیے');
  String get passwordTooShort => _translate('passwordTooShort', 'Password must be at least 6 characters', 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے');
  String get pleaseConfirmPassword => _translate('pleaseConfirmPassword', 'Please confirm your password', 'براہ کرم اپنے پاس ورڈ کی تصدیق کریں');
  String get passwordsDoNotMatch => _translate('passwordsDoNotMatch', 'Passwords do not match', 'پاس ورڈ مماثل نہیں ہیں');

  // ============ Error Messages ============
  String get noAccountFound => _translate('noAccountFound', 'No account found with this email', 'اس ای میل سے کوئی اکاؤنٹ نہیں ملا');
  String get incorrectPassword => _translate('incorrectPassword', 'Incorrect password', 'غلط پاس ورڈ');
  String get invalidEmail => _translate('invalidEmail', 'Invalid email address', 'غلط ای میل ایڈریس');
  String get invalidCredential => _translate('invalidCredential', 'Invalid email or password', 'غلط ای میل یا پاس ورڈ');
  String get loginFailed => _translate('loginFailed', 'Login failed. Please try again.', 'لاگ ان ناکام۔ براہ کرم دوبارہ کوشش کریں۔');
  String get emailAlreadyInUse => _translate('emailAlreadyInUse', 'An account already exists with this email', 'اس ای میل سے پہلے سے اکاؤنٹ موجود ہے');
  String get weakPassword => _translate('weakPassword', 'Password is too weak', 'پاس ورڈ بہت کمزور ہے');
  String get registrationFailed => _translate('registrationFailed', 'Registration failed. Please try again.', 'رجسٹریشن ناکام۔ براہ کرم دوبارہ کوشش کریں۔');
  String get enterEmailFirst => _translate('enterEmailFirst', 'Enter your email first', 'پہلے اپنا ای میل درج کریں');
  String get passwordResetEmailSent => _translate('passwordResetEmailSent', 'Password reset email sent', 'پاس ورڈ ری سیٹ ای میل بھیج دی گئی');

  // ============ Quiz Screen ============
  String get question => _translate('question', 'Question', 'سوال');
  String get leaveQuiz => _translate('leaveQuiz', 'Leave Quiz?', 'کوئز چھوڑیں؟');
  String get leaveQuizMessage => _translate('leaveQuizMessage', 'Your progress will be lost. Are you sure you want to leave?', 'آپ کی پیشرفت ضائع ہو جائے گی۔ کیا آپ واقعی چھوڑنا چاہتے ہیں؟');
  String get stay => _translate('stay', 'Stay', 'رہیں');
  String get leave => _translate('leave', 'Leave', 'چھوڑیں');
  String get mute => _translate('mute', 'Mute', 'خاموش');
  String get unmute => _translate('unmute', 'Unmute', 'آواز');
  String get noQuestionsAvailable => _translate('noQuestionsAvailable', 'No questions available for this difficulty', 'اس مشکل کی سطح کے لیے کوئی سوالات دستیاب نہیں');
  String get errorLoadingQuestions => _translate('errorLoadingQuestions', 'Error loading questions', 'سوالات لوڈ کرنے میں خرابی');

  // ============ Quiz Loading Tips ============
  String get tipAnswerQuickly => _translate('tipAnswerQuickly', 'Answer quickly for more points!', 'زیادہ پوائنٹس کے لیے جلدی جواب دیں!');
  String get tipTenSeconds => _translate('tipTenSeconds', 'You have 10 seconds per question', 'آپ کے پاس ہر سوال کے لیے 10 سیکنڈ ہیں');
  String get tipStayCalm => _translate('tipStayCalm', 'Stay calm and do your best!', 'پرسکون رہیں اور اپنی پوری کوشش کریں!');
  String get tipLearningIsFun => _translate('tipLearningIsFun', 'Learning is fun!', 'سیکھنا مزے کی بات ہے!');
  String get getReadyToTest => _translate('getReadyToTest', 'Get ready to test your knowledge!', 'اپنے علم کو جانچنے کے لیے تیار ہو جائیں!');

  // ============ Quiz Difficulty Labels ============
  String get beginner => _translate('beginner', 'Beginner', 'ابتدائی');
  String get normal => _translate('normal', 'Normal', 'عام');
  String preparingQuiz(String difficulty) => _translate('preparingQuiz', 'Preparing $difficulty Quiz', '$difficulty کوئز تیار ہو رہا ہے');

  // ============ Quiz Result Screen ============
  String get perfectScore => _translate('perfectScore', 'Perfect Score!', 'کامل سکور!');
  String get almostPerfect => _translate('almostPerfect', 'Almost Perfect!', 'تقریباً کامل!');
  String get excellent => _translate('excellent', 'Excellent!', 'بہترین!');
  String get goodJob => _translate('goodJob', 'Good Job!', 'شاباش!');
  String get niceTry => _translate('niceTry', 'Nice Try!', 'اچھی کوشش!');
  String get keepLearning => _translate('keepLearning', 'Keep Learning!', 'سیکھتے رہیں!');
  String get subhanAllahPerfect => _translate('subhanAllahPerfect', 'SubhanAllah! You answered everything perfectly!', 'سبحان اللہ! آپ نے سب کچھ بالکل صحیح جواب دیا!');
  String get mashaAllahAmazing => _translate('mashaAllahAmazing', 'MashaAllah! You did amazing!', 'ماشاءاللہ! آپ نے بہترین کارکردگی دکھائی!');
  String get keepLearningImproving => _translate('keepLearningImproving', 'Keep learning and improving!', 'سیکھتے اور بہتر ہوتے رہیں!');
  String get practiceMakesPerfect => _translate('practiceMakesPerfect', 'Practice makes perfect!', 'مشق سے کمال آتا ہے!');
  String get dontGiveUp => _translate('dontGiveUp', "Don't give up, try again!", 'ہمت نہ ہاریں، دوبارہ کوشش کریں!');
  String get pointsEarned => _translate('pointsEarned', 'POINTS EARNED', 'حاصل کردہ پوائنٹس');
  String get correct => _translate('correct', 'Correct', 'صحیح');
  String get wrong => _translate('wrong', 'Wrong', 'غلط');
  String get accuracy => _translate('accuracy', 'Accuracy', 'درستگی');
  String get playAgain => _translate('playAgain', 'Play Again', 'دوبارہ کھیلیں');
  String get home => _translate('home', 'Home', 'ہوم');
  String get mode => _translate('mode', 'MODE', 'موڈ');

  // ============ Scoring Info ============
  String get howScoringWorks => _translate('howScoringWorks', 'How Scoring Works', 'سکورنگ کیسے کام کرتی ہے');
  String get answerWithin3Seconds => _translate('answerWithin3Seconds', 'Answer within 3 seconds', '3 سیکنڈ میں جواب دیں');
  String get after3Seconds => _translate('after3Seconds', 'After 3 seconds', '3 سیکنڈ کے بعد');
  String get minimumPerCorrect => _translate('minimumPerCorrect', 'Minimum per correct', 'کم از کم فی صحیح');
  String get gotIt => _translate('gotIt', 'Got it!', 'سمجھ گیا!');
  String perfectAnswersLostPoints(int points) => _translate('perfectAnswersLostPoints', 'Perfect answers! Lost $points pts to time.', 'کامل جوابات! وقت کی وجہ سے $points پوائنٹس ضائع ہوئے۔');

  // ============ Admin ============
  String get adminAccess => _translate('adminAccess', 'Admin Access', 'ایڈمن رسائی');
  String get enterAdminPin => _translate('enterAdminPin', 'Enter admin PIN to continue', 'جاری رکھنے کے لیے ایڈمن پن درج کریں');
  String get pin => _translate('pin', 'PIN', 'پن');
  String get enter => _translate('enter', 'Enter', 'داخل کریں');
  String get incorrectPin => _translate('incorrectPin', 'Incorrect PIN', 'غلط پن');

  // ============ Helper Method ============
  String _translate(String key, String en, String ur) {
    switch (locale.languageCode) {
      case 'ur':
        return ur;
      default:
        return en;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ur'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
