import 'dart:async';

import 'operations/auth/data/data_sources/auth_remote_data_source.dart';
import 'operations/auth/domain/use_cases/sign_out_use_case.dart';
import 'operations/auth/presentation/screens/sign_in_screen.dart';
import 'screens/chat/chat_tab_picker.dart';
import 'screens/chat/regular_chat/immutable/chat_graphics_class.dart';
import 'screens/example_chat_tiles.dart';
import 'screens/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'injection.dart';
import 'operations/auth/current_user.dart';
import 'package:provider/provider.dart';

import 'operations/auth/presentation/blocs/auth_process_init/auth_proccess_cubit.dart';
import 'operations/auth/presentation/blocs/auth_process_init/auth_proccess_state.dart';

import 'operations/chat/regular_chat/presentation/ChatService.dart';
import 'operations/common/network_info.dart';


typedef AppBuilder = Future<Widget> Function();

Future<void> bootstrap(AppBuilder builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //WidgetsBinding.instance.addObserver(AppLifecycleListener());
  //FirebaseDatabase.instance.setPersistenceEnabled(true);

  const ChatGraphicsClass chatGraphicsClass =
          ChatGraphicsClass(
            messageAlreadyReadFormat: MessageAlreadyRead1(),
            chatTileLastMessageFormat: SnapchatStyleMessageWidget(),
              regularChatTileFormat: ChatTile1(),
              scrollingAndRefreshingFormat: RegularRefreshScroll(),
              chatroomContentFormat: DarkChatUi(),
              messageBubbleFormat: AdaptiveChatBubble(),
            picWidgetFormat:PicWidget1(), userNameInsteadOfName: true
          );
  initializeDependencies(chatGraphicsClass);


  runApp(await builder());
}

void main() {
  bootstrap(
        () async {




          serviceLocator<NetworkInfo>().initialize();
          //await CloudMessaging().configurePushNotifications();

      return App(
        regToken:'',
        currentUserOp: serviceLocator<CurrentUserOp>(),


      );
    },
  );
}

class App extends StatefulWidget {
  const App({
    super.key,

    required this.currentUserOp,

    this.regToken,
  });



  final String? regToken;
  final CurrentUserOp currentUserOp;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return MultiRepositoryProvider(
      providers: [
        ChangeNotifierProvider(create: (_) =>
          serviceLocator<ChatService>())
      ],
      child: BlocProvider(
        create: (context) => AuthInitializeProcessesCubit(

          chatService: serviceLocator<ChatService>(),
          signOutUseCase: serviceLocator<SignOutUseCase>(),
          currentUserOp: widget.currentUserOp, authRemoteDataSource: serviceLocator<AuthRemoteDataSource>(),
        )..enable(),
        child: MaterialApp(
          title: 'Clean Architecture',
          theme: darkTheme(),
          home: BlocConsumer<AuthInitializeProcessesCubit, AuthProcessState>(
            listener: (context, state) {

            },
            builder: (context, state) {

              if (state.loadingDependencies==true) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state.loggedIn==true) {

                return const ChatChooser();  // Navigate to the chat chooser if logged in
              } else if(state.loggedIn==false) {
                return const Scaffold(
                  body: Center(child: SignInScreen()),
                );
              }
              else{
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}




