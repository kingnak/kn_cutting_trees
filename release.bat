rmdir /Q /S distr
mkdir distr
mkdir distr\fomod
copy src\info.xml distr\fomod\info.xml
copy src\ModuleConfig.xml distr\fomod\ModuleConfig.xml
copy src\Changelog.txt distr\Changelog.txt

mkdir "distr\00 Core"
mkdir "distr\00 Core\scripts"
copy src\scripts\KN_CT_ActiveTreeScript.pex "distr\00 Core\scripts"
copy src\scripts\KN_CT_DisabledTreeScript.pex "distr\00 Core\scripts"
copy src\scripts\KN_CT_PlayerScript.pex "distr\00 Core\scripts"
copy src\scripts\KN_CT_TreeManagementScript.pex "distr\00 Core\scripts"

mkdir "distr\10 Plain SKSE"
mkdir "distr\10 Plain SKSE\scripts"
copy src\scripts\KN_CT_TreeManagementScriptSKSE.pex "distr\10 Plain SKSE\scripts"
copy src\KN_CuttingTrees.esp "distr\10 Plain SKSE"

mkdir "distr\11 Campfire SKSE"
mkdir "distr\11 Campfire SKSE\scripts"
copy src\scripts\KN_CT_TreeManagementScriptSKSE.pex "distr\11 Campfire SKSE\scripts"
copy src\scripts\KN_CT_TreeManagementSKSE_Campfire.pex "distr\11 Campfire SKSE\scripts"
copy src\KN_CuttingTrees_Campfire.esp "distr\11 Campfire SKSE"

mkdir "distr\20 Plain Lite"
mkdir "distr\20 Plain Lite\scripts"
copy src\scripts\KN_CT_TreeManagementScriptLite.pex "distr\20 Plain Lite\scripts"
copy src\KN_CuttingTreesLite.esp "distr\20 Plain Lite"

mkdir "distr\21 Campfire Lite"
mkdir "distr\21 Campfire Lite\scripts"
copy src\scripts\KN_CT_TreeManagementScriptLite.pex "distr\21 Campfire Lite\scripts"
copy src\scripts\KN_CT_TreeManagementLite_Campfire.pex "distr\21 Campfire Lite\scripts"
copy src\KN_CuttingTreesLite_Campfire.esp "distr\21 Campfire Lite"

cd distr
"C:\Program Files\7-Zip\7z.exe" a "KN Cutting Trees 2.0.7z" *
