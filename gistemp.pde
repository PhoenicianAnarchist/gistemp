int cell_width = 50;
int cell_height = 6;

color cold_colour = color(  0,   0, 200);
color zero_colour = color(100, 100, 100);
color warm_colour = color(200,   0,   0);

Table table_data;
int row_count;
int first_year;
String[] months;

int max_row = 0;
boolean is_animating = true;
PImage img;

void setup() {
  println("Loading Table...");
  table_data = loadTable("./out/GLB.Ts+dSST_trimmed.csv", "header");
  row_count = table_data.getRowCount();
  int col_count = table_data.getColumnCount();
  println(row_count, "rows.");
  println(col_count, "columns.");

  first_year = table_data.getRow(0).getInt(0);
  months = new String[12];
  TableRow r = table_data.getRow(0);
  for (int i = 0; i < 12; ++i) {
    months[i] = r.getColumnTitle(i + 1).strip();
  }

  // size() cannot contain expressions, surface.setSize() must be used instead
  int w = 12 * cell_width;
  int h = row_count * cell_height;
  surface.setSize(w, h);
}

void draw() {
  background(0);

  // cache image after animation is finished
  if (is_animating) {
    DrawCells(max_row);
    ++max_row;
  } else {
    image(img, 0, 0);
  }

  // Save image _before_ hover label is drawn!
  if (is_animating && (max_row > row_count)) {
    save("image.png");
    img = loadImage("image.png");
    is_animating = false;
  }

  // push hover label around when near edge to keep on screen
  int align_x = RIGHT;
  int x_offset = 0;
  if (mouseX <= 128) {
    align_x = LEFT;
    x_offset = 16;
  }

  int align_y = BOTTOM;
  int y_offset = 0;
  if (mouseY <= 32) {
    align_y = TOP;
    y_offset = 16;
  }
  textAlign(align_x, align_y);

  // index mouse position to table data
  int year_index = mouseY / cell_height;
  int month_index = mouseX / cell_width;
  int year = year_index + first_year;
  String month = months[month_index];
  float anomaly = table_data.getRow(year_index).getFloat(month_index + 1);

  String label = String.format("%s %d @ %.2f", month, year, anomaly);

  textSize(16);
  stroke(0);
  fill(200);
  text(label, mouseX + x_offset, mouseY + y_offset);
}

void DrawCells(int max_row) {
  noStroke();
  color c;

  for (int r = 0; r < max_row; ++r) {
    TableRow row = table_data.getRow(r);
    int y = r * cell_height;

    for (int m = 1; m <= 12; ++m) {
      int x = ((m - 1) * cell_width);

      // temperature anomaly is scaled so that the highs (>= 1.0) don't peak
      float t = row.getFloat(m) / 1.4;
      if (t < 0) {
        c = lerpColor(zero_colour, cold_colour, abs(t));
      } else {
        c = lerpColor(zero_colour, warm_colour, t);
      }

      fill(c);
      rect(x, y, cell_width, cell_height);
    }
  }
}
