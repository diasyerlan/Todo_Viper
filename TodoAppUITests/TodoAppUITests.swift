import XCTest
@testable import TodoApp

class TodoListPresenterTests: XCTestCase {
    
    var presenter: TodoListPresenter!
    var mockView: MockTodoListView!
    var mockInteractor: MockTodoListInteractor!
    var mockRouter: MockTodoListRouter!

    override func setUp() {
        super.setUp()
        
        // Initialize mock objects
        mockView = MockTodoListView()
        mockInteractor = MockTodoListInteractor()
        mockRouter = MockTodoListRouter()
        
        // Initialize the presenter with mocks
        presenter = TodoListPresenter()
        presenter.view = mockView
        presenter.interactor = mockInteractor
        presenter.router = mockRouter
    }

    override func tearDown() {
        presenter = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }

    // Test viewDidLoad, simulating a first launch scenario
    func testViewDidLoadFirstLaunch() {
        // Mock UserDefaults to simulate a first launch
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        
        // Call viewDidLoad
        presenter.viewDidLoad()
        
        // Verify interactor fetches todos
        XCTAssertTrue(mockInteractor.fetchTodoListCalled, "Interactor's fetchTodoList should be called on first launch")
    }
    
    // Test search functionality
    func testUpdateSearchResults() {
        // Given some todos
        let todo1 = Todo(todo: "Buy milk", completed: false, body: "Get 2 liters", date: Date())
        let todo2 = Todo(todo: "Walk the dog", completed: false, body: "In the park", date: Date())
        presenter.todos = [todo1, todo2]
        
        // Simulate a search with "milk"
        let searchController = UISearchController()
        searchController.searchBar.text = "milk"
        
        // Call updateSearchResults
        presenter.updateSearchResults(for: searchController)
        
        // Verify filteredTodos contains only the relevant todo
        XCTAssertEqual(presenter.filteredTodos.count, 1, "There should be only one filtered todo for search term 'milk'")
        XCTAssertEqual(presenter.filteredTodos[0], todo1, "The filtered todo should be 'Buy milk'")
    }

    // Test adding a new todo
    func testDidTapAddButton() {
        // Call didTapAddButton
        presenter.didTapAddButton()
        
        // Verify navigation to the edit screen with a new todo
        XCTAssertTrue(mockView.navigateToEditTodoScreenCalled, "The edit screen should be presented when adding a new todo")
    }

    // Test updating a todo
    func testDidUpdateTodo() {
        let todo = Todo(todo: "Buy milk", completed: false, body: "Get 2 liters", date: Date())
        presenter.todos = [todo]
        
        // Create an updated todo
        let updatedTodo = Todo(todo: "Buy milk", completed: true, body: "Get 2 liters", date: Date())
        
        // Call didUpdateTodo
        presenter.didUpdateTodo(updatedTodo)
        
        // Verify the todo is updated
        XCTAssertEqual(presenter.todos[0].completed, true, "The todo's 'completed' status should be updated")
    }

    // Test deleting a todo
    func testDidDeleteTodoAt() {
        let todo1 = Todo(todo: "Buy milk", completed: false, body: "Get 2 liters", date: Date())
        let todo2 = Todo(todo: "Walk the dog", completed: false, body: "In the park", date: Date())
        presenter.todos = [todo1, todo2]
        
        // Call didDeleteTodoAt with index 0 (deleting 'Buy milk')
        presenter.didDeleteTodoAt(index: 0)
        
        // Verify the todo is deleted
        XCTAssertEqual(presenter.todos.count, 1, "There should be one todo left after deletion")
        XCTAssertEqual(presenter.todos[0], todo2, "The remaining todo should be 'Walk the dog'")
    }

    // Test updating toolbar label
    func testUpdateToolbarLabel() {
        presenter.todos = [Todo(todo: "Buy milk", completed: false, body: "Get 2 liters", date: Date())]
        
        // Call updateToolbarLabel
        presenter.updateToolbarLabel()
        
        // Verify the toolbar label update
        XCTAssertEqual(mockView.toolbarLabelText, "1 задача", "The toolbar label should show the correct todo count")
    }
}

// MARK: - Mocks

class MockTodoListView: PresenterToViewTodoListProtocol {
    var navigateToEditTodoScreenCalled = false
    var toolbarLabelText: String?
    
    func showTodos() {}
    func updateToolbarLabel(with text: String) {
        toolbarLabelText = text
    }
    func navigateToEditTodoScreen(with viewController: UIViewController) {
        navigateToEditTodoScreenCalled = true
    }
    func onFetchTodoListFailure(error: String) {}
}

class MockTodoListInteractor: PresenterToInteractorTodoListProtocol {
    var presenter: (any TodoApp.InteractorToPresenterTodoListProtocol)?
    
    var todos: [TodoApp.Todo]?
    
    var fetchTodoListCalled = false
    
    func fetchTodoList() {
        fetchTodoListCalled = true
    }
}

class MockTodoListRouter: PresenterToRouterTodoListProtocol {
    static func createModule() -> UINavigationController? {
        return UINavigationController()
    }
    
    func navigateToTodoDetails(on view: PresenterToViewTodoListProtocol?, with todo: Todo) {}
}
