#include <vector>
#include <iostream>
#include <random>
#include <tuple>
#include <list>
#include <algorithm>
#include <string>
#include <iostream>
#include <cctype>

#define For3( a, a_lim, b, b_lim, c, c_lim) \
	for(int a = 0; a < a_lim; a++) \
		for(int b = 0; b < b_lim; b++ ) \
			for(int c = 0; c < c_lim; c++) \

#define For2( a, a_lim, b, b_lim) \
	for(int a = 0; a < a_lim; a++) \
		for(int b = 0; b < b_lim; b++ ) \

typedef std::vector<double> Line;
typedef std::vector<Line> Grid;
typedef std::vector<Grid> Cube;


//Global variables
auto gmaxselected = 0;
auto maxselected = 0;
auto selected = 0;

auto can_select = 0;

auto cycles = 400;
auto ants = 600;


//Input Grid
Grid a = Grid(9, Line(9, -1));

//Ant State
Grid digit_row;
Grid digit_column;
Cube places;
Grid digits;
Grid b;
Cube w;
Cube p;
std::vector<std::tuple<int, int>> not_selected_pos;


//Ants State
Cube t;

//Tmp States
Grid mb = Grid(9, Line(9,-1));
Grid gmb = Grid(9, Line(9, -1));


auto r = 0.9;

bool include_in_submatrix(int n, int i, int j)
{
	auto res = false;
	for (int subi = i * 3; subi < i * 3 + 3; subi++)
		for (int subj = j * 3; subj < j * 3 + 3; subj++)
			res = res || (b[subi][subj] == n);

	return res;
}

int how_many_places(int n, int i, int j)
{
	auto res = 0;
	auto is = i / 3;
	auto js = j / 3;
	if (!include_in_submatrix(n, is, js))
	{
		for (int subi = is * 3; subi < is * 3 + 3; subi++)
			for (int subj = js * 3; subj < js * 3 + 3; subj++)
				if (!digit_row[subi][n] && !digit_column[subj][n] && b[subi][subj] == -1) res++;

		return res;
	}

	return res;
}
//Place where I should add the number n in the submatrix i,j
std::tuple<int,int> place_to_add(int n, int i, int j)
{
	std::tuple<int,int> res;
	for (int subi = i * 3; subi < i * 3 + 3; subi++)
		for (int subj = j * 3; subj < j * 3 + 3; subj++)
			if (!digit_row[subi][n] && !digit_column[subj][n] && b[subi][subj] == -1)
			{
				res = std::make_tuple(subi, subj);
			}

	return res;
}

void update_places()
{
	For3(i, 9, j, 9, k, 9)
	{
		places[i][j][k] = how_many_places(k, i, j);
	}
}

void update_digits()
{
	for (int i = 0; i < 9; i++)
	{
		for (int j = 0; j < 9; j++)
		{
			auto how_many = 0;
			for (int k = 0; k < 9; k++)
			{
				if (!digit_row[i][k] && !digit_column[j][k] && places[i][j][k] != 0 && b[i][j] == -1)
				{
					how_many++;
				}
			}
			digits[i][j] = how_many;
		}
	}
}

void print_sudoku(Grid& sudoku)
{
	for (int i = 0; i < 9; i++)
	{
		for (int j = 0; j < 9; j++)
		{
			std::cout << sudoku[i][j] + 1 << " ";
			if ((j + 1) % 3 == 0) std::cout << " ";
		}

		std::cout << std::endl;
		if ((i + 1) % 3 == 0) std::cout << std::endl ;
	}
}

void print_sudoku()
{
	//Print b
	std::cout << "Actual solution (Selections: " << selected << " )" << std::endl;
	print_sudoku(b);

	std::cout << "Last solucion founded by an Ant: (Selection: " << maxselected << " )" << std::endl << std::endl;
	print_sudoku(mb);

	std::cout << "Last solucion founded by a group of Ants: (Selection: " << gmaxselected << " )" << std::endl << std::endl;
	print_sudoku(gmb);
}

void solve_sudoku()
{
	std::random_device rd;
	std::mt19937 gen(rd());

	std::uniform_real_distribution<> disf(0, 1);
	std::uniform_int_distribution<> disk(0, 8);

	t = Cube(9, Grid(9, Line(9, 1000)));
	for (auto cycle = 0; cycle < cycles; cycle++)
	{
		maxselected = 0;
		for (auto ant = 0; ant < ants; ant++)
		{
			w = Cube(9, Grid(9, Line(9, 0)));
			digit_row = Grid(9, Line(9, 0));
			digit_column = Grid(9, Line(9, 0));
			places = Cube(9, Grid(9, Line(9, 0)));
			digits = Grid(9, Line(9, 0));
			p = Cube(9, Grid(9, Line(9, 0)));

			not_selected_pos.clear();

			b = a;
			selected = 0;
			can_select = 1;

			For2(i, 9, j, 9)
			{
				auto t = std::make_tuple(i, j);
				not_selected_pos.push_back(t);
			}

			For2(i, 9, j, 9)
			{
				if (b[i][j] != -1)
				{
					auto digit = b[i][j];
					digit_row[i][digit] = 1;
					digit_column[j][digit] = 1;
					update_places();
					not_selected_pos.erase(std::remove(not_selected_pos.begin(), not_selected_pos.end(), std::make_tuple(i, j)), not_selected_pos.end());

					selected += 1;
				}
			}


			while (can_select)
			{
				auto initial_selected = selected; 
				auto d_selected = true;
				auto one_done = false;

				update_places();

				//En todas las subgrillas donde pueda poner algun numero solo una vez, lo agrego.
				For3(i, 9, j, 9, k, 9)
				{
					if (places[i][j][k] == 1)
					{
						auto pos = place_to_add(k, i / 3, j / 3);

						if (b[std::get<0>(pos)][std::get<1>(pos)] != -1 || k == -1)
						{
							int stop = 1;
						}

						b[std::get<0>(pos)][std::get<1>(pos)] = k;

						digit_row[std::get<0>(pos)][k] = 1;
						digit_column[std::get<1>(pos)][k] = 1;

						update_places();
						not_selected_pos.erase(std::remove(not_selected_pos.begin(), not_selected_pos.end(), std::make_tuple(i, j)), not_selected_pos.end());
						selected++;
						one_done = true;
					}

					d_selected &= (places[i][j][k] == 0);
					if (!d_selected)
					{
						int a = 0;
					}
				}

				can_select = !d_selected;

				d_selected = true;
				for (int i = 0; i < 9; i++)
				{
					for (int j = 0; j < 9; j++)
					{
						auto how_many = 0;
						auto lastone = 0;

						update_places();
						update_digits();
						for (int k = 0; k < 9; k++)
						{
							if (!digit_row[i][k] && !digit_column[j][k] && places[i][j][k] != 0 && b[i][j] == -1)
							{
								lastone = k;
							}
						}


						if (digits[i][j] == 1)
						{
							if (b[i][j] != -1 || lastone == -1)
							{
								int stop = 1;
							}

							b[i][j] = lastone;
							selected++;
							one_done = true;
							digit_row[i][lastone] = 1;
							digit_column[j][lastone] = 1;
							update_places();
							not_selected_pos.erase(std::remove(not_selected_pos.begin(), not_selected_pos.end(), std::make_tuple(i, j)), not_selected_pos.end());
						}

						if (digits[i][j] == 0)
						{
							not_selected_pos.erase(std::remove(not_selected_pos.begin(), not_selected_pos.end(), std::make_tuple(i, j)), not_selected_pos.end());
						}

						d_selected &= (digits[i][j] == 0);
					}
				}

				can_select = !d_selected && can_select;

				auto sumW = 0;
				for (int i = 0; i < 9; i++)
				{
					for (int j = 0; j < 9; j++)
					{
						for (int k = 0; k < 9; k++)
						{
							w[i][j][k] = t[i][j][k] * (10 - places[i][j][k])*(10 - digits[i][j]);
							sumW += w[i][j][k];
						}

					}
				}

				auto sumP = 0;
				double maxP = 0;
				for (int j = 0; j < 9; j++)
				{
					for (int i = 0; i < 9; i++)
					{
						for (int k = 0; k < 9; k++)
						{
							p[i][j][k] = w[i][j][k] / sumW;
							sumP += p[i][j][k];
							if (maxP < p[i][j][k])
							{
								maxP = p[i][j][k];
							}
						}
					}
				}


				update_digits();

				if (!one_done && not_selected_pos.size() > 0)
				{
					auto prom = maxP;

					float sumpp = 0;
					int randi, randj, randk, randpos;

					while (sumpp <= prom)
					{
						std::uniform_int_distribution<> dis(0, not_selected_pos.size() - 1);
						randpos = dis(gen);
						randi = std::get<0>(not_selected_pos[randpos]);
						randj = std::get<1>(not_selected_pos[randpos]);

						if (digits[randi][randj] == 0) continue;

						randk = disk(gen);
						while (digit_row[randi][randk] || digit_column[randj][randk] || include_in_submatrix(randk, randi / 3, randj / 3))
						{
							randk = disk(gen);
						}

						sumpp += p[randi][randj][randk];
					}

					if (sumpp >= prom && digits[randi][randj] != 0)
					{
						if (b[randi][randj] == -1 && (!digit_row[randi][randk] && !digit_column[randj][randk] && !include_in_submatrix(randk, randi / 3, randj / 3)))
						{
							if (b[randi][randj] != -1 || randk == -1)
							{
								int stop = 1;
							}

							b[randi][randj] = randk;

							digit_row[randi][randk] = 1;
							digit_column[randj][randk] = 1;
							update_places();
							not_selected_pos.erase(std::remove(not_selected_pos.begin(), not_selected_pos.end(), std::make_tuple(randi, randj)), not_selected_pos.end());

							selected++;
						}
					}
				}


				if (selected == 81) can_select = 0;
				
				if (selected != initial_selected)
				{
					system("cls");
					std::cout << "Cycle: " << cycle << " of " << cycles << std::endl;
					std::cout << "Ant: " << ant << " of " << ants << std::endl;
					std::cout << "Selected: " << selected << std::endl << std::endl << std::endl;
					print_sudoku();
				}

			}

			system("cls");
			std::cout << "Cycle: " << cycle << " of " << cycles << std::endl;
			std::cout << "Ant: " << ant << " of " << ants << std::endl;
			std::cout << "Selected: " << selected << std::endl << std::endl;
			print_sudoku();

			if (selected == 81)
			{
				int stop = 1;
				break;
			}

			if (selected > maxselected)
			{
				maxselected = selected;
				mb = b;
			}
		}

		auto dt = maxselected / 81;
		for (int j = 0; j < 9; j++)
			for (int i = 0; i < 9; i++)
				for (int k = 0; k < 9; k++)
					t[i][j][k] *= r;

		for (int j = 0; j < 9; j++)
			for (int i = 0; i < 9; i++)
			{
				if (mb[i][j] != -1)
				{
					auto k = mb[i][j];
					t[i][j][k] += dt;
				}
			}

		if (maxselected > gmaxselected)
		{
			gmaxselected = selected;
			gmb = mb;
		}

		if (selected == 81)
		{
			break;
		}
	}
}

#include <fstream>

#if defined(_DEBUG) || defined(NDEBUG) 
#define TESTS_PATH "../local_tests/"
#endif

int main()
{
	std::ifstream file;
	std::string test = "ws34e.txt";
	
	file.open(TESTS_PATH + test);

	int v = -1;
	For2(i, 9, j, 9)
	{
		file >> v;
		a[i][j] = v-1;
	}

	//print_sudoku(a);
	solve_sudoku();
	
}