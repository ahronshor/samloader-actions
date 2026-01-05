# Upgrade Summary - GNSF Integration

## מה השתנה?

### קבצים חדשים שנוצרו:
1. **`gnsf.py`** - הכלי המשודרג להורדת קושחות סמסונג (מועתק מ-gnsf repo)
2. **`csclist.py`** - רשימת קודי CSC (מועתק מ-gnsf repo)
3. **`gnsf.sh`** - סקריפט wrapper חדש שמריץ את gnsf.py
4. **`README.md`** - מדריך שימוש מלא באנגלית
5. **`EXAMPLES_HE.md`** - דוגמאות שימוש בעברית
6. **`.gitignore`** - מניעת העלאת קבצים זמניים

### קבצים ששונו:
1. **`.github/workflows/main.yml`** - Workflow מעודכן עם inputs פשוטים יותר

### קבצים ישנים (נשארו ללא שינוי):
1. **`sam.sh`** - הסקריפט הישן (ניתן למחוק אם רוצה)
2. **`tools/worker.sh`** - הסקריפט הישן לחילוץ (ניתן למחוק אם רוצה)

## איך זה עובד עכשיו?

### לפני (ישן):
```yaml
inputs:
  - model: SM-X135G
  - model_name: sm-x135g
  - imei: 123456789012345
  - version: .*
```
הבעיה: samloader לא עובד טוב, צריך 4 inputs, לא תמיד מוצא גרסאות

### אחרי (חדש):
```yaml
inputs:
  - gnsf_command: "./gnsf.py -m SM-X135G -r XFV -i YOUR_IMEI download -v 'VERSION' -O ./downloads"
  - imei: 123456789012345
```
היתרונות:
- רק 2 inputs
- שימוש ב-gnsf.py המשודרג
- הורדות מהירות ויציבות יותר
- תמיכה בשיטות אימות חדשות של סמסונג

## תהליך ה-Workflow

1. **Checkout** - מוריד את הקוד מ-GitHub
2. **Install** - מתקין Python, pip, ותלויות (requests, pycryptodome, tqdm)
3. **Set Env** - מגדיר משתני סביבה (GNSF_COMMAND, IMEI)
4. **Run gnsf.sh** - מריץ את הסקריפט:
   - מחליף את `YOUR_IMEI` ב-IMEI האמיתי
   - **מריץ את gnsf.py להורדה + פענוח אוטומטי** ✨
     - gnsf.py מוריד את הקובץ המוצפן (.enc2 או .enc4)
     - gnsf.py מפענח אוטומטית ומוחק את הקובץ המוצפן
     - מחזיר קובץ .zip או .tar.md5 מפוענח
   - מחלץ את הקבצים מה-firmware archive
   - פותח את ה-AP partition
   - מחלץ boot/init_boot/vbmeta/recovery/dtbo images
   - יוצר tar files עבור Magisk
   - מעתיק הכל לתיקיית Dist/
5. **Upload** - מעלה את הקבצים ל-DigitalOcean Spaces

## קבצי פלט

בסוף התהליך מתקבלים:
1. **`{model}-{version}.zip`** - הקושחה המלאה המקורית
2. **`{model}-{version}-magisk.tar`** - Boot images מחולצים עבור Magisk

## דוגמה מלאה

### Input ב-GitHub Actions:
```
GNSF Command:
./gnsf.py -m SM-X135G -r XFV -i YOUR_IMEI download -v "X135GDXU1AYH5/X135GOJM1AYI1/X135GDXU1AYH5/X135GDXU1AYH5" -O ./downloads

IMEI:
123456789012345
```

### פקודה שמתבצעת בפועל:
```bash
./gnsf.py -m SM-X135G -r XFV -i 123456789012345 download -v "X135GDXU1AYH5/X135GOJM1AYI1/X135GDXU1AYH5/X135GDXU1AYH5" -O ./downloads
```

### קבצים שנוצרים:
```
Dist/
├── sm-x135g-X135GDXU1AYH5.zip          (הקושחה המלאה)
└── sm-x135g-X135GDXU1AYH5-magisk.tar   (Boot images)
```

### תוכן המגיסק tar:
```
sm-x135g-X135GDXU1AYH5-magisk.tar
└── SM-X135G/
    └── Magisk-Patch-Me-SM-X135G.tar
        ├── boot.img
        ├── init_boot.img  (אם קיים)
        ├── vbmeta.img
        ├── recovery.img
        └── dtbo.img
```

## בדיקות שכדאי לעשות

### מקומי (לפני push):
```bash
# בדוק תחביר bash
bash -n gnsf.sh

# בדוק Python syntax
python3 -m py_compile gnsf.py

# בדוק שה-workflow תקין
yamllint .github/workflows/main.yml  # אם yamllint מותקן
```

### ב-GitHub Actions:
1. הרץ workflow עם דוגמה אמיתית
2. בדוק שהקבצים נוצרים ב-Dist/
3. בדוק שההעלאה ל-Spaces עובדת

## הסרת קוד ישן (אופציונלי)

אם הכל עובד טוב, אפשר למחוק:
```bash
rm sam.sh
rm -rf tools/
```

## שדרוגים עתידיים

רעיונות לשיפורים:
1. הוספת cache ל-Python dependencies
2. הוספת notifications (Telegram/Discord) כשההורדה מסתיימת
3. אוטומציה מלאה - בדיקת עדכונים אוטומטית
4. תמיכה במספר מכשירים בפעולה אחת

## קרדיטים

- **GNSF Original**: Vladislav Tislenko (keklick1337)
- **Samloader Actions**: @ravindu644
- **Integration**: Moshe Shor
