const API = "/api/tasks";


async function loadTasks() {

    const response = await fetch(API);

    const tasks = await response.json();

    const container =
        document.getElementById("tasks");

    container.innerHTML = "";

    tasks.forEach(task => {

        const element =
            document.createElement("div");

        element.className = "task";

        element.innerHTML = `

            <div>

                <h3 class="${task.completed ? "completed" : ""}">
                    ${task.title}
                </h3>

                <p>
                    ${task.description || ""}
                </p>

            </div>

            <div>

                <button
                    onclick="
                        toggleTask(
                            ${task.id},
                            ${task.completed}
                        )
                    "
                >
                    ${task.completed
                        ? "Undo"
                        : "Complete"}
                </button>

                <button
                    class="delete"
                    onclick="
                        deleteTask(${task.id})
                    "
                >
                    Delete
                </button>

            </div>
        `;

        container.appendChild(element);
    });
}


document
    .getElementById("taskForm")
    .addEventListener(
        "submit",
        async event => {

            event.preventDefault();

            const title =
                document.getElementById(
                    "title"
                ).value;

            const description =
                document.getElementById(
                    "description"
                ).value;

            await fetch(API, {

                method: "POST",

                headers: {
                    "Content-Type":
                        "application/json"
                },

                body: JSON.stringify({
                    title,
                    description
                })
            });

            event.target.reset();

            loadTasks();
        }
    );


async function toggleTask(
    id,
    completed
) {

    await fetch(`${API}/${id}`, {

        method: "PUT",

        headers: {
            "Content-Type":
                "application/json"
        },

        body: JSON.stringify({
            completed: completed ? 0 : 1
        })
    });

    loadTasks();
}


async function deleteTask(id) {

    if (!confirm(
        "Delete this task?"
    )) {
        return;
    }

    await fetch(`${API}/${id}`, {
        method: "DELETE"
    });

    loadTasks();
}


loadTasks();
