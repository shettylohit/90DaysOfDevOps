const express = require("express");
const mongoose = require("mongoose");
const path = require("path");
require("dotenv").config();

const Task = require("./models/Task");

const app = express();

const PORT = process.env.PORT || 3000;


// Middleware
app.use(express.json());

app.use(express.static(
    path.join(__dirname, "public")
));


// Connect MongoDB
mongoose
    .connect(process.env.MONGO_URI)
    .then(() => {
        console.log("MongoDB connected");
    })
    .catch(error => {
        console.error("MongoDB connection error:", error);
    });


// GET all tasks
app.get("/api/tasks", async (req, res) => {

    try {

        const tasks = await Task.find()
            .sort({ createdAt: -1 });

        res.json(tasks);

    } catch (error) {

        res.status(500).json({
            error: "Failed to fetch tasks"
        });
    }
});


// GET one task
app.get("/api/tasks/:id", async (req, res) => {

    try {

        const task = await Task.findById(req.params.id);

        if (!task) {
            return res.status(404).json({
                error: "Task not found"
            });
        }

        res.json(task);

    } catch (error) {

        res.status(500).json({
            error: "Failed to fetch task"
        });
    }
});


// CREATE task
app.post("/api/tasks", async (req, res) => {

    try {

        const {
            title,
            description
        } = req.body;

        if (!title) {
            return res.status(400).json({
                error: "Title is required"
            });
        }

        const task = await Task.create({
            title,
            description
        });

        res.status(201).json(task);

    } catch (error) {

        res.status(500).json({
            error: "Failed to create task"
        });
    }
});


// UPDATE task
app.put("/api/tasks/:id", async (req, res) => {

    try {

        const task = await Task.findByIdAndUpdate(
            req.params.id,
            req.body,
            {
                new: true,
                runValidators: true
            }
        );

        if (!task) {
            return res.status(404).json({
                error: "Task not found"
            });
        }

        res.json(task);

    } catch (error) {

        res.status(500).json({
            error: "Failed to update task"
        });
    }
});


// DELETE task
app.delete("/api/tasks/:id", async (req, res) => {

    try {

        const task = await Task.findByIdAndDelete(
            req.params.id
        );

        if (!task) {
            return res.status(404).json({
                error: "Task not found"
            });
        }

        res.json({
            message: "Task deleted successfully"
        });

    } catch (error) {

        res.status(500).json({
            error: "Failed to delete task"
        });
    }
});


// Start server
app.listen(PORT, () => {

    console.log(
        `Server running at http://localhost:${PORT}`
    );

});
