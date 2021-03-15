import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:torn_pda/models/chaining/target_model.dart';
import 'package:torn_pda/providers/friends_provider.dart';
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/user_details_provider.dart';
import 'package:torn_pda/utils/api_caller.dart';
import 'package:provider/provider.dart';

enum ProfileCheckType {
  profile,
  attack,
}

class ProfileAttackCheckWidget extends StatefulWidget {
  final int profileId;
  final String apiKey;
  final ProfileCheckType profileCheckType;

  ProfileAttackCheckWidget(
      {@required this.profileId,
      @required this.apiKey,
      @required this.profileCheckType,
      @required Key key})
      : super(key: key);

  @override
  _ProfileAttackCheckWidgetState createState() =>
      _ProfileAttackCheckWidgetState();
}

class _ProfileAttackCheckWidgetState extends State<ProfileAttackCheckWidget> {
  Future _checkedPerson;
  bool _infoToShow = false;
  bool _errorToShow = false;

  Widget _mainDetailsWidget = SizedBox.shrink();

  UserDetailsProvider _userDetails;
  var _expandableController = ExpandableController();

  @override
  void initState() {
    super.initState();
    _userDetails = context.read<UserDetailsProvider>();

    _checkedPerson = _fetchAndAssess();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkedPerson,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_infoToShow) {
            return ExpandablePanel(
              controller: _expandableController,
              expanded: _mainDetailsWidget,
            );
          } else if (_errorToShow) {
            return ExpandablePanel(
              controller: _expandableController,
              expanded: _mainDetailsWidget,
            );
          } else {
            return SizedBox.shrink();
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  Future<void> _fetchAndAssess() async {
    var target = await TornApiCaller.target(
      widget.apiKey,
      widget.profileId.toString(),
    ).getTarget;

    // FRIEND CHECK
    var isFriend = false;
    var friendsProv = context.read<FriendsProvider>();
    if (!friendsProv.initialized) {
      await friendsProv.initFriends();
    }
    for (var friend in friendsProv.allFriends) {
      if (friend.playerId == widget.profileId) isFriend = true;
    }

    var isTornPda = false;
    var isPartner = false;

    var isOwnPlayer = false;
    var isOwnFaction = false;
    var isFriendlyFaction = false;
    // This one will take own player, own faction or friendly faction (so that
    // we don't show them separately, but by importance (first one self, then
    // own faction and lastly friendly faction)
    var playerOrFaction = false;

    if (target is TargetModel) {
      if (target.playerId == 2225097) {
        isTornPda = true;
      }

      if (target.married.spouseId == _userDetails.basic.playerId) {
        isPartner = true;
      }

      if (target.playerId == _userDetails.basic.playerId) {
        isOwnPlayer = true;
        playerOrFaction = true;
      }

      if (target.faction.factionId == _userDetails.basic.faction.factionId) {
        isOwnFaction = true;
        playerOrFaction = true;
      }

      var settingsProvider = context.read<SettingsProvider>();
      for (var fact in settingsProvider.friendlyFactions) {
        if (target.faction.factionId == fact.id) {
          isFriendlyFaction = true;
          break;
        }
      }

      if ((isTornPda || isPartner || isFriend || isFriendlyFaction || playerOrFaction) && mounted) {
        Widget tornPdaDetails = SizedBox.shrink();
        Widget partnerDetails = SizedBox.shrink();
        Widget friendsDetails = SizedBox.shrink();
        Widget friendlyFactionDetails = SizedBox.shrink();
        Widget playerOrFactionDetails = SizedBox.shrink();
        Color backgroundColor = Colors.transparent;

        if (isTornPda) {
          tornPdaDetails = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'images/icons/torn_pda.png',
                width: 16,
                height: 16,
                //color: Colors.brown[400],
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Hi! Thank you for using Torn PDA!",
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }

        if (isFriend) {
          Color friendTextColor = Colors.green;
          String friendText = "This is a friend of yours!";
          if (widget.profileCheckType == ProfileCheckType.attack) {
            friendTextColor = Colors.black;
            friendText = "CAUTION: this is a friend of yours!";
            backgroundColor = Colors.red;
          }
          friendsDetails = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.people,
                color: friendTextColor,
                size: 15,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  friendText,
                  style: TextStyle(
                    color: friendTextColor,
                    fontSize: 12,
                    fontWeight: friendText.contains("CAUTION")
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        }

        if (isOwnPlayer) {
          playerOrFactionDetails = Row(
            children: [
              Icon(
                MdiIcons.heart,
                color: Colors.green,
                size: 16,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  "This is you, you're beautiful!",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        } else if (isOwnFaction) {
          String factionText = "This is a fellow faction member "
              "(${target.faction.position.toLowerCase()})!";
          Color factionColor = Colors.green;
          if (widget.profileCheckType == ProfileCheckType.attack) {
            factionColor = Colors.black;
            factionText = "CAUTION: this is a fellow faction member!";
            backgroundColor = Colors.red;
          }
          playerOrFactionDetails = Row(
            children: [
              Image.asset(
                'images/icons/faction.png',
                width: 15,
                height: 12,
                color: factionColor,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  factionText,
                  style: TextStyle(
                    color: factionColor,
                    fontWeight: factionText.contains("CAUTION")
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        } else if (isFriendlyFaction) {
          String factionText = "This is an allied faction member "
              "(${target.faction.factionName})!";
          Color factionColor = Colors.green;
          if (widget.profileCheckType == ProfileCheckType.attack) {
            factionColor = Colors.black;
            factionText = "CAUTION: this is an allied faction member!";
            backgroundColor = Colors.red;
          }

          friendlyFactionDetails = Row(
            children: [
              Image.asset(
                'images/icons/faction.png',
                width: 15,
                height: 12,
                color: factionColor,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  factionText,
                  style: TextStyle(
                    color: factionColor,
                    fontWeight: factionText.contains("CAUTION")
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }

        if (isPartner) {
          String partnerText = "This is your lovely "
              "${target.gender == "Male" ? "husband" : "wife"}!";
          Color partnerColor = Colors.green;
          if (widget.profileCheckType == ProfileCheckType.attack) {
            partnerColor = Colors.black;
            partnerText = "CAUTION: this is your "
                "${target.gender == "Male" ? "husband" : "wife"}! "
                "Are you really that mad at "
                "${target.gender == "Male" ? "him" : "her"}?";
            backgroundColor = Colors.red;
          }

          partnerDetails = Row(
            children: [
              Icon(
                MdiIcons.heart,
                color: partnerColor,
                size: 16,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  partnerText,
                  style: TextStyle(
                    color: partnerColor,
                    fontWeight: partnerText.contains("CAUTION")
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }

        Widget mainWidgetBox = Container(
          color: backgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tornPdaDetails,
                      if (isTornPda && isPartner) SizedBox(height: 8),
                      partnerDetails,
                      if ((isTornPda || isPartner) && isFriend) SizedBox(height: 8),
                      friendsDetails,
                      if ((isTornPda || isPartner || isFriend) && playerOrFaction)
                        SizedBox(height: 8),
                      playerOrFactionDetails,
                      if ((isTornPda || isPartner || isFriend || playerOrFaction) &&
                          isFriendlyFaction)
                        SizedBox(height: 8),
                      friendlyFactionDetails,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        setState(() {
          _mainDetailsWidget = mainWidgetBox;
          _infoToShow = true;
          _expandableController.expanded = true;
        });
      }
    } else {
      Widget errorDetails = Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Text(
            "Error contacting API (no details available)",
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
        ),
      );

      setState(() {
        _errorToShow = true;
        _expandableController.expanded = true;
        _mainDetailsWidget = errorDetails;
      });
    }
  }
}
