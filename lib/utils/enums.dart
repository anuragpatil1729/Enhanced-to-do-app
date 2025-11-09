enum Priority { low, medium, high }
enum FilterMode { all, active, completed, overdue }
enum SortMode { byDueDate, byPriority, byCreated }

enum Reminder { atTime, fiveMin, fifteenMin, oneHour, oneDay }

String describePriority(Priority p) {
  switch (p) {
    case Priority.low:
      return 'Low';
    case Priority.medium:
      return 'Medium';
    case Priority.high:
      return 'High';
  }
}

String describeReminder(Reminder r) {
  switch (r) {
    case Reminder.atTime:
      return 'At time of due date';
    case Reminder.fiveMin:
      return '5 minutes before';
    case Reminder.fifteenMin:
      return '15 minutes before';
    case Reminder.oneHour:
      return '1 hour before';
    case Reminder.oneDay:
      return '1 day before';
  }
}
