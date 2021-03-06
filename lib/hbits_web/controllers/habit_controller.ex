defmodule HbitsWeb.HabitController do
  use HbitsWeb, :controller

  alias Hbits.Habits
  alias Hbits.Habits.Habit

  def index(conn, _params) do
    habits = Habits.list_habits()
    render(conn, "index.html", habits: habits)
  end

  def new(conn, _params) do
    changeset = Habits.change_habit(%Habit{})
    render(conn, "new.html", changeset: changeset)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"habit" => habit_params}) do
    user_id = conn.assigns.current_user.id
    habit_params = Map.put(habit_params, "user_id", user_id)
    case Habits.create_habit(habit_params) do
      {:ok, habit} ->
        conn
        |> put_flash(:info, "Habit created successfully.")
        |> redirect(to: Routes.habit_path(conn, :show, habit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    habit = Habits.get_habit!(id)
    render(conn, "show.html", habit: habit)
  end

  def edit(conn, %{"id" => id}) do
    habit = Habits.get_habit!(id)
    changeset = Habits.change_habit(habit)
    render(conn, "edit.html", habit: habit, changeset: changeset)
  end

  def update(conn, %{"id" => id, "habit" => habit_params}) do
    habit = Habits.get_habit!(id)

    case Habits.update_habit(habit, habit_params) do
      {:ok, habit} ->
        conn
        |> put_flash(:info, "Habit updated successfully.")
        |> redirect(to: Routes.habit_path(conn, :show, habit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", habit: habit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    habit = Habits.get_habit!(id)
    {:ok, _habit} = Habits.delete_habit(habit)

    conn
    |> put_flash(:info, "Habit deleted successfully.")
    |> redirect(to: Routes.habit_path(conn, :index))
  end
end
