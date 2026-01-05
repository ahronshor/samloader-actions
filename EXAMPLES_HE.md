# דוגמאות שימוש - Samloader Actions GNSF

## דוגמה מהירה

### שלב 1: בדוק אם יש עדכון זמין
ראשית, תריץ את הפקודה הזאת מקומית כדי לבדוק איזה גרסה זמינה:

```bash
./gnsf.py -m SM-X135G -r XFV -i 123456789012345 checkupdate
```

זה יחזיר משהו כמו:
```
X135GDXU1AYH5/X135GOJM1AYI1/X135GDXU1AYH5/X135GDXU1AYH5
```

### שלב 2: הרץ את ה-Workflow
עכשיו תעבור ל-GitHub Actions ותכניס:

**Input 1 - GNSF Command:**
```
./gnsf.py -m SM-X135G -r XFV -i YOUR_IMEI download -v "X135GDXU1AYH5/X135GOJM1AYI1/X135GDXU1AYH5/X135GDXU1AYH5" -O ./downloads
```

**Input 2 - IMEI:**
```
123456789012345
```

### שלב 3: המתן לסיום
ה-workflow יוריד את הקושחה, יחלץ את הקבצים, ויעלה ל-DigitalOcean Spaces:
- `sm-x135g-X135GDXU1AYH5.zip` - הקושחה המלאה
- `sm-x135g-X135GDXU1AYH5-magisk.tar` - קבצי Boot עבור Magisk

## מודלים נפוצים

### Galaxy Tab A9+ (SM-X115)
```bash
# בדיקת עדכון
./gnsf.py -m SM-X115 -r ILO -i YOUR_IMEI checkupdate

# פקודה ל-GitHub Actions
./gnsf.py -m SM-X115 -r ILO -i YOUR_IMEI download -v "VERSION_HERE" -O ./downloads
```

### Galaxy Tab A9 (SM-X110)
```bash
# בדיקת עדכון
./gnsf.py -m SM-X110 -r ILO -i YOUR_IMEI checkupdate

# פקודה ל-GitHub Actions
./gnsf.py -m SM-X110 -r ILO -i YOUR_IMEI download -v "VERSION_HERE" -O ./downloads
```

### Galaxy S24 Ultra (SM-S928B)
```bash
# בדיקת עדכון
./gnsf.py -m SM-S928B -r XFV -i YOUR_IMEI checkupdate

# פקודה ל-GitHub Actions
./gnsf.py -m SM-S928B -r XFV -i YOUR_IMEI download -v "VERSION_HERE" -O ./downloads
```

## קודי אזור (CSC) נפוצים

- `ILO` - ישראל (Orange)
- `PTR` - ישראל (Partner)
- `PCL` - ישראל (Pelephone)
- `CEL` - ישראל (Cellcom)
- `XFV` - אירופה (Generic)
- `DBT` - גרמניה
- `BTU` - בריטניה

## פתרון בעיות

### שגיאה: "Invalid IMEI"
- ודא שה-IMEI הוא בדיוק 15 ספרות
- ודא שה-IMEI תואם למודל המכשיר

### שגיאה: "Version not found"
- הרץ `checkupdate` כדי לקבל את הגרסה המדויקת
- נסה אזור (CSC) אחר

### שגיאה: "Download failed"
- בדוק שהמודל נכון (רישיות)
- בדוק שקוד האזור תואם למודל
- נסה להריץ שוב - לפעמים שרתי סמסונג עמוסים

## טיפים

1. **שמור על IMEI פרטי** - אל תשתף את ה-IMEI המלא שלך באינטרנט
2. **בדוק גרסה קודם** - תמיד הרץ `checkupdate` לפני download
3. **גיבוי קודם** - תמיד גבה את הקושחה הנוכחית לפני שינוי
4. **Magisk עדכני** - השתמש בגרסת Magisk עדכנית לטלאי Boot
