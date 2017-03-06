// encoding=utf-8
PRODUCT_NAME=KCD
PRODUCT_EXTENSION=app
BUILD_PATH=./build
DEPLOYMENT=Release
APP_BUNDLE=$(PRODUCT_NAME).$(PRODUCT_EXTENSION)
APP=$(BUILD_PATH)/$(DEPLOYMENT)/$(APP_BUNDLE)
APP_NAME=$(BUILD_PATH)/$(DEPLOYMENT)/$(PRODUCT_NAME)
SCHEME=KCD
INFO_PLIST=KCD/KCD-Info.plist

LOCALIZE_FILES=KCD/BroserWindowController.m KCD/ServerDataStore.m KCD/KenzoDockStatus.m \
KCD/MissionStatus.m KCD/NyukyoDockStatus.m KCD/CreateSlotItemCommand.m KCD/AppDelegate.m \
KCD/StoreCreateSlotItemHistoryCommand.m KCD/DocksViewController.m KCD/SlotItemWindowController.m \
KCD/BroserWindowController.m KCD/ExternalBrowserWindowController.m KCD/LengTransformer.m \
KCD/SokuTransformer.m KCD/GameViewController.m KCD/UpgradableShipsWindowController.m \
KCD/ScreenshotListWindowController.m KCD/HistoryWindowController.m KCD/BridgeViewController.m \
KCD/TimeSignalNotifier.m KCD/ActinKindTransformer.m KCD/AirbasePlaneStateTransformer.m

VER_CMD=grep -A1 'CFBundleShortVersionString' $(INFO_PLIST) | tail -1 | tr -d "'\t</string>" 
VERSION=$(shell $(VER_CMD))

all: package

Localizable: $(LOCALIZE_FILES)
	genstrings -o KCD/ja.lproj $^
	(cd KCD/ja.lproj; ${MAKE} $@;)
#	genstrings -o KCD/en.lproj $^
#	(cd KCD/en.lproj; ${MAKE} $@;)
	genstrings -o KCD/zh-Hant-TW.lproj $^
	(cd KCD/zh-Hant-TW.lproj; ${MAKE} $@;)


checkLocalizable:
#	(cd KCD/en.lproj; ${MAKE} $@;)
	(cd KCD/ja.lproj; ${MAKE} $@;)
	(cd KCD/zh-Hant-TW.lproj; ${MAKE} $@;)

deploy:
	test -z "`git status --porcelain`"

release: updateRevision
	xcodebuild -derivedDataPath=build -configuration $(DEPLOYMENT)
	$(MAKE) restoreInfoPlist

package: deploy release
	REV=`git rev-parse --short HEAD`;	\
	ditto -ck -rsrc --keepParent $(APP) $(APP_NAME)-$(VERSION)-$${REV}.zip

updateRevision:
	if [ ! -f $(INFO_PLIST).bak ] ; then cp $(INFO_PLIST) $(INFO_PLIST).bak ; fi ;	\
	REV=`git rev-parse --short HEAD` ;	\
	sed -e "s/%%%%REVISION%%%%/$${REV}/" $(INFO_PLIST) > $(INFO_PLIST).r ;	\
	mv -f $(INFO_PLIST).r $(INFO_PLIST) ;	\

restoreInfoPlist:
	if [ -f $(INFO_PLIST).bak ] ; then mv -f $(INFO_PLIST).bak $(INFO_PLIST) ; fi

build/Release/EquipmentEnhancementListBuilder: EquipmentEnhancementListBuilder/main.swift KCD/EnhancementListItem.swift
	xcodebuild -derivedDataPath=build -configuration $(DEPLOYMENT) -target EquipmentEnhancementListBuilder

buildEquipmentEnhancementList: build/Release/EquipmentEnhancementListBuilder
	./build/Release/EquipmentEnhancementListBuilder ./KCD
