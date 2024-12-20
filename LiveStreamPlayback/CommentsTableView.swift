class CommentsTableView: UITableView, UITableViewDataSource {
    private var comments: [Comment] = []

    init() {
        super.init(frame: .zero, style: .plain)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.separatorStyle = .none
        self.rowHeight = UITableView.automaticDimension
        self.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateComments(_ comments: [Comment]) {
        self.comments = comments
        self.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = comments[indexPath.row].comment
        cell.textLabel?.textColor = .white
        return cell
    }
}
