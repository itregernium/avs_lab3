#!/bin/sh
set -e

SEED=${1:-123456}

rand() {
  n=$1
  if [ "$n" -le 0 ]; then
    echo "ERROR: rand modulus must be > 0" >&2
    exit 1
  fi
  SEED=$(( (SEED * 1103515245 + 12345) % 2147483648 ))
  echo $(( SEED % n ))
}



pick() {
  list="$1"
  count=0
  for _ in $list; do count=$((count + 1)); done
  idx=$(rand "$count")
  i=0
  for item in $list; do
    if [ "$i" -eq "$idx" ]; then
      echo "$item"
      return
    fi
    i=$((i + 1))
  done
}

FILES="secrets config run todo requirements cursor notes log data"
WORDS="алгосы кронва биржа засыпашки пара здоровый_сон сон колок экзамен первак вязьма тест теормин зачет незачет"
BRANCHES="pr_feature gguf hotfix hf_tests backend_cuda backend_metal server_last"

LAB_DIR="lab3_repo_$SEED"
rm -rf "$LAB_DIR"
mkdir "$LAB_DIR"
cd "$LAB_DIR"

git init -q
git checkout -q -b main

echo "init" > init.txt
git add init.txt
git commit -q -m "init"

for i in $(seq 1 5); do
  FILE=$(pick "$FILES")
  WORD=$(pick "$WORDS")
  echo "$WORD $i" > "$FILE.txt"
  git add "$FILE.txt"
  git commit -q -m "add $FILE.txt $i"
done

BASE_COMMIT=$(git rev-parse HEAD)

CONFLICT_FILE=$(pick "$FILES")
git checkout -q -b feature1 "$BASE_COMMIT"
echo "feature1 modification" > "$CONFLICT_FILE.txt"
git add "$CONFLICT_FILE.txt"
git commit -q -m "feature1 change"

git checkout -q -b feature2 "$BASE_COMMIT"
echo "feature2 modification" > "$CONFLICT_FILE.txt"
git add "$CONFLICT_FILE.txt"
git commit -q -m "feature2 change"

for BR in $BRANCHES; do
  if git show-ref --quiet refs/heads/"$BR"; then
    continue
  fi
  git checkout -q -b "$BR" main
  git checkout -q main
done

TASK_ID=1
echo "Лабораторная работа №3 (вариант $SEED)"
echo "---------------------------------------"
echo ""
echo "В этой лабораторной работе вам предстоит освоить систему контроля версий Git"
echo ""
echo "Задания:"

FILE1=$(pick "$FILES"); WORD1=$(pick "$WORDS")
echo "$TASK_ID) Добавьте строку \"$WORD1\" в файл $FILE1.txt и сделайте коммит"
TASK_ID=$((TASK_ID + 1))

FILE2=$(pick "$FILES"); WORD3=$(pick "$WORDS")
echo "$TASK_ID) Измените файл $FILE2.txt, добавьте строку \"не $WORD3\" и сделайте коммит"
TASK_ID=$((TASK_ID + 1))

BR1=$(pick "$BRANCHES"); FILE3=$(pick "$FILES"); WORD4=$(pick "$WORDS")
echo "$TASK_ID) Перейдите на ветку '$BR1', добавьте строку \"$WORD4\" в файл $FILE3.txt и сделайте коммит"
TASK_ID=$((TASK_ID + 1))

echo "$TASK_ID) Посмотрите разницу между последними двумя коммитами и сохраните вывод в файл diff.txt"
TASK_ID=$((TASK_ID + 1))

FILE4=$(pick "$FILES"); WORD5=$(pick "$WORDS")
echo "$TASK_ID) Откатитесь к 3-му коммиту на ветке main, измените файл $FILE4.txt, добавьте строку \"$WORD5\" и сделайте новый коммит"
TASK_ID=$((TASK_ID + 1))

BR2=$(pick "$BRANCHES")
echo "$TASK_ID) Перейдите на ветку '$BR2' и выполните rebase на main. Разрешите возможные конфликты"
TASK_ID=$((TASK_ID + 1))

echo "$TASK_ID) Слейте ветки feature1 и feature2 в main. Конфликт возникнет автоматически, разрешите его и сделайте merge-коммит"
TASK_ID=$((TASK_ID + 1))

echo "$TASK_ID) Создайте ветку 'release' от main и слейте в неё все изменения"
TASK_ID=$((TASK_ID + 1))

echo ""
echo "-1) Создайте аккаунт на github.com и оформите ваш репозиторий"
echo "    Заполните bio, измените аватар, создайте README репозиторий, прочие кастомизации"
echo "    (за хорошее оформление +баллы)"
echo ""
echo "После выполнения всех заданий сохраните историю всех коммитов в файл history.txt:"
echo ""
echo "tip: Проверить историю можно командой:"
echo "   git log --oneline --graph --all"
echo ""
