"""Feature/model checks; generated points test code, never stand in for measurements."""
import importlib.util
import unittest
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('palette', ROOT / 'palette_experiment.py')
palette = importlib.util.module_from_spec(spec)
spec.loader.exec_module(palette)


class PaletteTests(unittest.TestCase):
    def test_features_use_absolute_clear_and_ignore_white_calibration(self):
        row = dict(R_Hz=100, G_Hz=200, B_Hz=50, C_Hz=400, scale_pct=100, settled=1,
                   brightness=-1, r=0, g=0, b=1)
        clear, x = palette.features(row)
        self.assertEqual(clear, 400)
        np.testing.assert_allclose(x, [.25, .5, .125, np.log1p(400)])
        np.testing.assert_allclose(palette.features(row, 'rgb')[1], [2/7, 4/7, 1/7, np.log1p(400)])
        for key in ['R_Hz', 'G_Hz', 'B_Hz', 'C_Hz']:
            row[key] *= .2
        row['scale_pct'] = 20
        np.testing.assert_allclose(palette.features(row)[1], x)
        row['settled'] = 0
        with self.assertRaises(ValueError):
            palette.features(row)
        row.update(settled=1, C_Hz=0)
        with self.assertRaises(ValueError):
            palette.features(row)

    def test_clear_distinguishes_identical_rgb_ratios_and_rejects_outliers(self):
        rng = np.random.default_rng(72)
        x = np.vstack([rng.normal([.3, .2, .4, np.log1p(c)], [.002]*4, (100, 4))
                       for c in [100, 4000]])
        labels = np.array(['Black']*100 + ['Blue']*100)
        model = palette.fit_centroids(x, labels, ['Black', 'Blue'])
        nearest, accepted = palette.predict(model, x)
        np.testing.assert_array_equal(nearest, np.r_[np.zeros(100), np.ones(100)])
        self.assertGreater(accepted.mean(), .95)
        _, accepted = palette.predict(model, np.array([[10, 10, 10, 10]]))
        self.assertFalse(accepted[0])
        model['dark_clear_hz'] = 200
        _, accepted = palette.predict(model, x[:100])
        self.assertFalse(accepted.any())
        lines = palette.model_lines(model)
        self.assertTrue(lines[0].startswith('@N 2 '))
        self.assertEqual(lines[-1], '@W')
        self.assertLessEqual(max(map(len, lines)), 191)
        model['classes'][0]['name'] = 'bad name'
        with self.assertRaises(ValueError):
            palette.model_lines(model)

    def test_colour_only_keeps_clear_but_ignores_it_in_distance(self):
        x = np.array([[.1, .2, .3, 3], [.11, .21, .31, 4],
                      [.6, .5, .1, 5], [.61, .51, .11, 6]])
        labels = np.array(['A', 'A', 'B', 'B'])
        model = palette.fit_centroids(x, labels, ['A', 'B'], clear_weight=0)
        self.assertEqual(model['inv_std'][3], 0)
        changed = x.copy()
        changed[:, 3] += 10
        nearest, accepted = palette.predict(model, x)
        other, other_accepted = palette.predict(model, changed)
        np.testing.assert_array_equal(nearest, other)
        np.testing.assert_array_equal(accepted, other_accepted)
        self.assertTrue(palette.model_lines(model)[0].startswith('@N 2'))

    def test_fit_standardization_uses_only_training_rows(self):
        x = np.array([[.1, .2, .3, 3], [.2, .3, .4, 4], [.3, .4, .5, 5], [.4, .5, .6, 6]])
        model = palette.fit_centroids(x[:2], np.array(['A', 'B']), ['A', 'B'])
        np.testing.assert_allclose(model['mean'], x[:2].mean(axis=0))
        self.assertFalse(np.allclose(model['mean'], x.mean(axis=0)))


if __name__ == '__main__':
    unittest.main()
