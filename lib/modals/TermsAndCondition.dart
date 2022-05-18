import 'package:flutter/material.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Preferences/UserPreferences.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/constants/palettes.dart';

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Flexible(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Terms of Use',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Palette.primaryColor,
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'The Owlet aims to connect business owners to customers. We want to help entrepreneurs to expand their business, reach, visibility, and sales. It is an online marketplace that makes it easier to gain new customers as businesses/freelancers can reach a wider variety of customers who may not have heard of their product or service.',
                            style: TextStyle(color: Colors.black87),
                          ),
                          SizedBox(height: 10),
                          RuleItem(
                            title: 'Inappropriate Posts',
                            description:
                                'You are not allowed to post lewd, obscene, or graphic images. You are also not allowed to post sexual photos of any kind. You are not allowed to post partially nude or completely nude photos',
                          ),
                          RuleItem(
                            title: 'Age Limit',
                            description:
                                ' You must be at least 13 years old to use this service.',
                          ),
                          RuleItem(
                            title: 'Password Security',
                            description:
                                ' You are to protect your password and guard access to your account. You are accountable for every activity You are solely accountable for your conduct on the app. You are also responsible for any text, audio, video, graphic, photo, profile, audio, and link (content) that you submit, post, and display on the Owlet.',
                          ),
                          RuleItem(
                            title: 'Rules of engagement',
                            description:
                                ' You must not abuse, harass, or threaten other owlet users. Abusive language or any form of online harassment can lead to suspension or even deletion of account. There is no tolerance for abusive users and reports of abusive language are taken seriousl',
                          ),
                          RuleItem(
                            title: 'Copyright Laws',
                            description:
                                ' You must not violate copyright laws. You must not violate intellectual property rights.',
                          ),
                          RuleItem(
                            title: 'Spamming',
                            description:
                                ' You must not send multiple unsolicited messages that can be diagnosed as spam.',
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Data Policy',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Palette.primaryColor,
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Container(
                            child: Text(
                              'What kind of data do we collect?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          SizedBox(height: 10),
                          RuleItem(
                            title: 'We collect:',
                            description:
                                ' We collect your personal data in order to provide you with the best products and services. We collect, use, and store identity data, contact data, delivery address, and financial data. We collect data on how you use the Owlet, the various types of content you view/engage. We also study the features that you use frequently and the actions you take in order to create a better product. We study the accounts you interact with. We collect data on account activity. We track the time, how long, and how frequently you use the Owlet app.',
                          ),
                          RuleItem(
                            title: 'Transactions:',
                            description:
                                ' We keep records of transactions performed on the app. We keep a record of accounts and bank information on transactions performed on the Owlet app. This is to prevent fraud and reduce misunderstanding.',
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(
                              'How do we use this information? We use consumer data:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          SizedBox(height: 10),
                          RuleItem(
                            title:
                                'To personalize and continuously improve the app',
                            description:
                                'We use your information to bring you a more personal experience when using the app. We also use the data to improve the product. We use the information to provide notifications for preferences, options, and so much more.',
                          ),
                          RuleItem(
                            title: 'For analytics and marketing',
                            description:
                                'We use data from you to analyze what you want and how to bring it to you. We collect data to measure the efficacy of marketing strategies. We track analytics to see how we can improve our service to you. We track the raw numbers and use them for marketing and improving your consumer experience.',
                          ),
                          RuleItem(
                            title: 'For security',
                            description:
                                'We collect data to ensure user security, prevent harmful conduct, block spam and ensure a digitally healthy and safe environment for our users.',
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RuleItem(
                            title: 'NOTE:',
                            description:
                                'We reserve all rights not expressly granted. We also reserve the right to adjust the data policies as we see fit.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        press: () => Navigator.pop(context),
                        text: 'Cancel',
                        paddingVert: 5,
                        paddingHori: 25,
                        textColor: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Button(
                        press: () {
                          UserPreferences().registerAppToDevice;
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushReplacementNamed(NavScreen.routeName);
                        },
                        text: 'I agree',
                        paddingVert: 5,
                        paddingHori: 25,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RuleItem extends StatelessWidget {
  const RuleItem({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Text(
            '- $title',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.centerLeft,
        ),
        Text('$description'),
        SizedBox(height: 7)
      ],
    );
  }
}
