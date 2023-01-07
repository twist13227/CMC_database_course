import random

tables = open('tables.txt', 'r+')
for line in tables:
    print(line, end='')

groups = []

f = open('names.txt', 'r+')
names = list(f.readlines())
f = open('surnames.txt', 'r+')
surnames = list(f.readlines())
f = open('patronymic.txt', 'r+')
patronymic = list(f.readlines())
'''id = 1
print('COPY schedule.students(student_id, surname, name, patronymic, info) FROM stdin;')
for i in range(1, 41701):
    for j in range(1, 7):
        for k in range(1, 6):
            for l in range(1, 21):
                print(str(id), end='\t')
                name_1 = random.randint(0, len(names) - 1)
                surname_1 = random.randint(0, len(surnames) - 1)
                patronymic_1 = random.randint(0, len(patronymic) - 1)
                print(names[name_1][0:len(names[name_1]) - 1], end='\t')
                print(surnames[surname_1][0:len(surnames[surname_1]) - 1], end='\t')
                print(patronymic[patronymic_1][0:len(patronymic[patronymic_1]) - 1], end='\t')
                print("{\"Факультет\": \"%s\", \"Курс\": %d, \"Группа\": %d}" %
                        ('Факультет ' + str(i), j, j * 100 + k))
                id += 1
            groups += [j * 100 + k]
print('\.') '''

for i in range(1, 41701):
    for j in range(1, 7):
        for k in range(1, 6):
            groups += [j * 100 + k]

examiners = []
for i in range(1, 250001):
    surname_2 = random.randint(0, len(surnames) - 1)
    examiners += [surnames[surname_2][0:len(surnames[surname_2]) - 1]]

subjects = [
    'Линейная алгебра', 'Математический анализ', 'Классическая механика', 'ОСИ',
    'Математический анализ', 'Теория множеств', 'Функциональный анализ', 'Прикладная алгебра',
    'Механика', 'Математический анализ', 'Квантовая механика', 'Электродинамика',
    'Биология', 'Высшая математика', 'Анатомия', 'Программирование',
    'Социология', 'Философия', 'Русский язык и культура речи', 'История',
    'Физика', 'История', 'География', 'Математический анализ',
    'Картография', 'Высшая математика', 'Физика', 'Экономика',
    'Фармацевтика', 'Химия', 'Гистология', 'Анатомия',
    'Релятивистская механика', 'Астрономия', 'Космонавтика', 'Программирование',
    'Социология', 'История', 'Философия', 'Экономика', 'Астрономия',
    'Высшая математика', 'География', 'Русский язык', 'Геометрия',
    'Аналитическая геометрия', 'Общая алгебра', 'Естествознание', 'Гимнастика',
    'Правоведение', 'Топология', 'Дискретная математика', 'Латынь', 'Нумерология',
    'Теория чисел', 'Астрология', 'Базы данных', 'Компьютерные сети', 'Ядро ОС', 'ТФКП'
]
type = ['Экзамен', 'Зачет']
dates = []
subjs = []
base = "2020-06-"
for i in range(1, 1000001):
    number = random.randint(1, 30)
    subject = random.choice(subjects)
    converted_num = "% s" % number
    date = base + converted_num
    dates.append(date)
    subjs.append(subject)
exams = []
id = 1
print('BEGIN;')
print('COPY schedule.exams(exam_id, reporting, subject_name, date, examiners_ids, examiners_surnames, faculty, groups) FROM stdin;')
for i in range(1, 1000001):
    print(str(id), end='\t')
    print(random.choice(type), end='\t')
    print(subjs[i-1], end='\t')
    print(dates[i-1], end='\t')
    print('{', end='')
    for j in range(1, 6):
        print(str((i - 1) * 5 + j), end='')
        if j != 5:
            print(', ', end='')
    print('}', end='\t')
    print('{', end='')
    for j in range(0, 5):
        print(examiners[((i - 1) * 5 + j) % 250000], end='')
        if j != 4:
            print(', ', end='')
    print('}', end='\t')
    print('Факультет ' + str(((i - 1) // 24) + 1), end='\t')
    print('{', end='')
    for j in range(0, 5):
        print(str(groups[((i - 1) * 5 + j) % 1251000]), end='')
        if j != 4:
            print(', ', end='')
    print('}')
    exams += [subject]
    id += 1
print('\.')

em_id = 1
print('COPY schedule.examiners(examiner_id, surname, name, patronymic, age) FROM stdin;')
for i in range(1, 250001):
    print(str(em_id), end='\t')
    name_2 = random.randint(0, len(names) - 1)
    patronymic_2 = random.randint(0, len(patronymic) - 1)
    print(examiners[i - 1], end='\t')
    print(names[name_2][0:len(names[name_2]) - 1], end='\t')
    print(patronymic[patronymic_2][0:len(patronymic[patronymic_2]) - 1], end='\t')
    print(str(random.randint(26, 85)))
    em_id += 1
print('\.')

feedbacks = [
    'Похороны',
    'Душка',
    'Смотрит на объем билета, а не на содержание',
    'Задаёт только любимые вопросы',
    'Любит поговорить о жизни',
    'Удос обеспечен',
    'Благодаря нему у меня ещё осталась стипендия',
    'Лучший',
    'Спасибо за то, что лишил стипендии',
    'Принимает хорошо, не душит',
    'Зависит от настроения',
    'Любит брать своих',
    'Свою группу не валит, до остальных докапывается',
    'Валит всех подряд',
    'Бегите',
    'Теорию не смотрит, только задачи',
    'На билет не смотрит, сразу доп. вопросы',
    'Самое главное - теормин',
    'Принимает только формулировки из своих лекций',
    'Самый быстрый человек, чтобы получить пересдачу',
    'Гоняет по всей программе'
]
rate = [1,5,4,4,4,5,5,5,2,5,3,4,4,1,1,4,4,4,2,1,2]
st_id = 1
ex_id = 1
print('COPY schedule.feedbacks(feedback_id, exam_id, subject_name, date, examiner_id, examiner_surname, feedback, rate, student_info) FROM stdin;')
for i in range(1, 100000001):
    print(str(i), end='\t')
    print(str((i-1) % 1000000 + 1), end='\t')
    ex_id += 1
    print(subjs[(i-1) % 1000000], end='\t')
    print(dates[(i-1) % 1000000], end='\t')
    ind = random.randint(0,5)
    print(str(((i - 1) * 5 + ind) % 250000 + 1), end='\t')
    print(examiners[((i - 1) * 5 + ind) % 250000], end='\t')
    f_num = (i - 1) // 24 + 1
    gr_num = groups[((i - 1) * 5 + random.randint(0,5)) % 1251000]
    c_num = gr_num // 100
    print(feedbacks[i % 22 - 1], end='\t')
    print(str(rate[i % 22 - 1]), end='\t')
    print("{\"Студенческий\": %d, \"Факультет\": \"%s\", \"Курс\": %d, \"Группа\": %d}" %
                        (st_id + random.randint(0, 100),'Факультет ' + str(f_num), c_num, gr_num))
    if ((ex_id - 1) % 6 == 0):
        st_id -= 500
    else:
        st_id += 100
    if ((ex_id - 1) % 24 == 0):
        st_id += 600
    st_id = (st_id - 1) % 25020000 + 1
print('\.')
print('COMMIT;')


'''print('COPY schedule.feedbacks(exam_id, student_id, examiner_id, subject_name, examiner_surname, feedback) FROM stdin;')
for i in range(1, 25000001):
    print(str(i % 1000000 + 1), end='\t')
    print(str(i), end='\t')
    print(str((i  % 1000000 + 1) * 5 - 1), end='\t')
    print(exams[i % 1000000 - 1], end='\t')
    print(examiners[(i  % 1000000 + 1) * 5 - 1], end='\t')
    print(random.choice(feedbacks))
print('\.')

print('COPY schedule.feedbacks(student_id, examiner_id, subject_name, examiner_surname, feedback) FROM stdin;')
for i in range(1, 25000001):
    print(str(i + 1), end='\t')
    print(str((i  % 1000000 + 1) * 5), end='\t')
    print(exams[i % 1000000], end='\t')
    print(examiners[(i  % 1000000 + 1) * 5 - 1], end='\t')
    print(random.choice(feedbacks))
print('\.')

print('COPY schedule.feedbacks(examiner_id, subject_name, examiner_surname, feedback) FROM stdin;')
for i in range(1, 50000001):
    print(str(i % 5000000 + 1), end='\t')
    print(exams[i % 1000000 - 1], end='\t')
    print(examiners[i % 5000000], end='\t')
    print(random.choice(feedbacks))
print('\.') '''























