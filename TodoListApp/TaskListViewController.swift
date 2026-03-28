import UIKit
import CoreData

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var tasks: [Task] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Task List"

        tableView.delegate = self
        tableView.dataSource = self

        fetchTasks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTasks()
    }

    func fetchTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            tasks = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TaskCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
            UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        cell.textLabel?.text = tasks[indexPath.row].name ?? ""
        return cell
    }

    // MARK: - Swipe Actions

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            let taskToDelete = self.tasks[indexPath.row]
            self.context.delete(taskToDelete)
            self.tasks.remove(at: indexPath.row)
            self.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler in
            let task = self.tasks[indexPath.row]

            let alert = UIAlertController(title: "Edit Task",
                                          message: "Enter a new task name",
                                          preferredStyle: .alert)

            alert.addTextField { textField in
                textField.text = task.name
                textField.placeholder = "Task name"
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }

            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !newName.isEmpty else {
                    completionHandler(false)
                    return
                }

                task.name = newName
                self.saveContext()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }

            alert.addAction(cancelAction)
            alert.addAction(saveAction)

            self.present(alert, animated: true)
        }

        editAction.backgroundColor = .systemBlue

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
