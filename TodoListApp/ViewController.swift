import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var taskTextField: UITextField!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do App"
    }

    @IBAction func saveTaskTapped(_ sender: UIButton) {
        guard let taskName = taskTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !taskName.isEmpty else {
            let alert = UIAlertController(title: "Missing Task", message: "Please enter a task name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let newTask = Task(context: context)
        newTask.name = taskName

        do {
            try context.save()
            print("Task saved successfully")
            taskTextField.text = ""
        } catch {
            print("Save error: \(error)")
        }
    }

    @IBAction func viewTasksTapped(_ sender: UIButton) {
        print("View tapped")
    }
}
