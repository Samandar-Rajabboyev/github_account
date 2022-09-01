import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/svg.dart';
import 'package:githun_account/models/account_model.dart';
import 'package:githun_account/utils.dart';
import 'package:githun_account/widgets/cached_image.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';
import '../models/repo_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  AccountModel? accountModel;
  List<RepoModel> repos = [];
  Map<String, String> headers = {"Accept": "application/json; charset=UTF-8"};
  String apiAccount = "https://api.github.com/users/Samandar-Rajabboyev";
  String apiRepos = "https://api.github.com/users/Samandar-Rajabboyev/repos";
  String defaultUrl = "https://github.com/Samandar-Rajabboyev";
  Map languageColors = {};

  _copyUrl(RepoModel repo) {
    FlutterClipboard.copy((repo.cloneUrl ?? defaultUrl)).then((value) => Utils.showToast("Copied!"));
  }

  Future<void> _fetchAccountData() async {
    Uri url = Uri.parse(apiAccount);
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      accountModel = accountModelFromJson(response.body);
    } else {
      Utils.showToast("failed to get data");
    }
  }

  Future<void> _fetchRepoList() async {
    Uri url = Uri.parse(apiRepos);
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      for (var element in list) {
        repos.add(RepoModel.fromJson(element));
      }
    } else {
      Utils.showToast("failed to get data");
    }
  }

  Future<String> _loadLanguageColorsJson() {
    return rootBundle.loadString('assets/json/language_colors.json');
  }

  _getColorsMap() async {
    languageColors = jsonDecode(await _loadLanguageColorsJson());
  }

  _init() {
    _isLoading = true;

    _getColorsMap();
    _fetchAccountData().then((value) {
      _fetchRepoList().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Image.asset(
          picGithubLogo,
          width: 45,
          height: 45,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: textColor),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // #avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: CachedImage(
                          imageUrl: (accountModel?.avatarUrl ?? ''),
                          fit: BoxFit.cover,
                          width: 65,
                          height: 65,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // #fullname
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse((accountModel?.htmlUrl ?? defaultUrl))),
                        child: Text(
                          (accountModel?.login ?? '(no data)'),
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SvgPicture.asset(icon2Users, color: textColor, width: 17, height: 17),
                      Text(
                        " ${accountModel?.followers} followers",
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        " • ${accountModel?.following} following",
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  MaterialButton(
                    onPressed: () {},
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: btnBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: btnBorder, width: 1),
                    ),
                    elevation: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Repositories",
                          style: TextStyle(
                            color: btnText,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: btnBorder,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            "${accountModel?.publicRepos}",
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: ListView.builder(
                      itemCount: repos.length,
                      itemBuilder: (context, index) => itemOfRepo(repos[index]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget itemOfRepo(RepoModel repo) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse((repo.htmlUrl ?? defaultUrl))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: btnBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    (repo.name ?? "(no data)"),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: accountFg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Text(
                    ((repo.private ?? false) ? "Private" : "Public"),
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            repo.description == null
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      (repo.description ?? ''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(70),
                    color: Colour((languageColors[(repo.language ?? 'Dart')] ?? "#00B4AB")),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  (repo.language ?? 'Dart'),
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  CupertinoIcons.star,
                  color: textColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  (repo.stargazersCount.toString()),
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _copyUrl(repo),
                  child: Container(
                    width: 27,
                    height: 27,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: btnBorder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.rectangle_on_rectangle,
                      color: textColor,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
