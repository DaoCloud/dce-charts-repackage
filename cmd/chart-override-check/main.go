package main

import (
	"errors"
	"flag"
	"fmt"
	"gopkg.in/yaml.v2"
	"os"
	"path"
	"path/filepath"
	"reflect"
	"strings"
)

var chartPath = flag.String("path", "", "root path of chart")
var skipCPath = flag.String("skipCPath", "", "config path of key list of skip check")

func main() {
	flag.Parse()
	if *chartPath == "" {
		fmt.Println("path can't be empty")
		fmt.Println("Usage: \n\tchart-override-check -path CHART_ROOT_PATH")
		os.Exit(1)
	}

	res, err := DiffChartValues(*chartPath, *skipCPath)
	if err != nil {
		fmt.Println(err)
		os.Exit(2)
	}

	if len(res.Result) == 0 {
		fmt.Printf("Check Pass: %d\n", res.DependencyCount)
	} else {
		fmt.Printf("Check Pass: %d, Failed: %d\n", res.DependencyCount-len(res.Result), len(res.Result))
		for name, items := range res.Result {
			fmt.Printf("Dependency: %s\n", name)
			for _, item := range items {
				if item.SubChartKeyNotFound {
					fmt.Printf("  key:%s, not found in sub chart\n", item.OverrideKey)
				} else {
					fmt.Printf("  key:%s, kind: '%s' != '%s' \n", item.OverrideKey, item.OverrideKeyKind, item.SubChartKeyKind)
				}
			}
		}
		os.Exit(3)
	}
}

func DiffChartValues(chartPath, skipCheckKeyPath string) (*Summary, error) {
	chart, err := GetChartDependencies(chartPath)
	if err != nil {
		return nil, err
	}

	parentValues, err := GetChartValues(filepath.Join(chartPath, "values.yaml"))
	if err != nil {
		return nil, err
	}

	chartSkipKeyList, err := GetSkipList(skipCheckKeyPath)
	if err != nil {
		fmt.Println(err)
	}

	res := make(map[string][]DifferenceItem, 0)

	for _, dependency := range chart.Dependencies {
		overrideValue, ok := parentValues[dependency.Name]
		if !ok {
			continue
		}

		skipKeyList, ok := chartSkipKeyList[dependency.Name]
		if !ok {
			skipKeyList = make([]string, 0)
		}

		overrideKeyList := BuildValuesKeyList("", skipKeyList, overrideValue)

		subChartValues, err := GetChartValues(filepath.Join(chartPath, "charts", dependency.Name, "values.yaml"))
		if err != nil {
			return nil, fmt.Errorf("read sub chart %s with error: %v", dependency.Name, err)
		}
		subChartKeyList := BuildValuesKeyList("", []string{}, subChartValues)

		subChartKeyMap := make(map[string]string)
		overrideKeyMap := make(map[string]string)

		for _, item := range overrideKeyList {
			overrideKeyMap[item.Key] = item.Kind
		}

		for _, item := range subChartKeyList {
			if item.IsNull == true {
				// auto filter
				for overrideKey := range overrideKeyMap {
					if strings.HasPrefix(overrideKey, item.Key) {
						delete(overrideKeyMap, overrideKey)
					}
				}
			}
			subChartKeyMap[item.Key] = item.Kind
		}

		differenceItemList := make([]DifferenceItem, 0)

		for overrideKey, overrideKind := range overrideKeyMap {
			subChartKind, ok := subChartKeyMap[overrideKey]
			if !ok {
				differenceItemList = append(differenceItemList, DifferenceItem{
					OverrideKey:         overrideKey,
					OverrideKeyKind:     overrideKind,
					SubChartKeyNotFound: true,
				})
				continue
			}
			if subChartKind != overrideKind {
				differenceItemList = append(differenceItemList, DifferenceItem{
					OverrideKey:         overrideKey,
					OverrideKeyKind:     overrideKind,
					SubChartKeyNotFound: false,
					SubChartKeyKind:     subChartKind,
				})
			}
		}

		if len(differenceItemList) != 0 {
			res[dependency.Name] = differenceItemList
		}
	}

	return &Summary{
		DependencyCount: len(chart.Dependencies),
		Result:          res,
	}, nil
}

type Summary struct {
	DependencyCount int
	Result          map[string][]DifferenceItem
}

type DifferenceItem struct {
	OverrideKey         string
	OverrideKeyKind     string
	SubChartKeyNotFound bool
	SubChartKeyKind     string
}

type Chart struct {
	Dependencies []Dependency `yaml:"dependencies"`
}

type Dependency struct {
	Name string `yaml:"name"`
}

func GetChartDependencies(chartPath string) (*Chart, error) {
	raw, err := os.ReadFile(filepath.Join(chartPath, "Chart.yaml"))
	if err != nil {
		return nil, fmt.Errorf("read Chart.yaml with error: %s", err)
	}

	chart := Chart{Dependencies: make([]Dependency, 0)}
	err = yaml.Unmarshal(raw, &chart)
	if err != nil {
		return nil, fmt.Errorf("unmarshal dependencies of chart with error: %s", err)
	}

	return &chart, nil
}

func GetChartValues(valuesPath string) (map[string]interface{}, error) {
	raw, err := os.ReadFile(valuesPath)
	if err != nil {
		return nil, err
	}
	values := make(map[string]interface{}, 0)
	err = yaml.Unmarshal(raw, &values)
	if err != nil {
		return nil, err
	}
	return values, nil
}

type KeyPath struct {
	Key    string
	Kind   string
	IsNull bool
}

func BuildValuesKeyList(root string, skipPaths []string, values interface{}) []KeyPath {
	res := make([]KeyPath, 0)

	for _, key := range skipPaths {
		if strings.HasPrefix(root, key) {
			return res
		}
	}

	if values == nil {
		return []KeyPath{{
			Key:    root,
			Kind:   "unknown",
			IsNull: true,
		}}
	}

	kind := reflect.TypeOf(values).Kind().String()
	switch kind {
	case "int":
		return []KeyPath{{
			Key:  root,
			Kind: "number",
		}}
	case "int32":
		return []KeyPath{{
			Key:  root,
			Kind: "number",
		}}
	case "int64":
		return []KeyPath{{
			Key:  root,
			Kind: "number",
		}}
	case "float":
		return []KeyPath{{
			Key:  root,
			Kind: "number",
		}}
	case "float32":
		return []KeyPath{{
			Key:  root,
			Kind: "number",
		}}
	case "float64":
		return []KeyPath{{
			Key:  root,
			Kind: "number",
		}}
	case "string":
		return []KeyPath{{
			Key:  root,
			Kind: "string",
		}}
	case "bool":
		return []KeyPath{{
			Key:  root,
			Kind: "bool",
		}}
	case "slice":
		return []KeyPath{{
			Key:  root,
			Kind: "slice",
		}}
	case "map":
		valuesNodeMap, ok := values.(map[string]interface{})
		if valuesNodeMap == nil {
			valuesNodeMap = make(map[string]interface{}, 0)
		}
		if !ok {
			valuesNodeInterfaceMap, ok := values.(map[interface{}]interface{})
			if !ok {
				fmt.Println("convert failed")
				return res
			}
			for key, val := range valuesNodeInterfaceMap {
				valuesNodeMap[key.(string)] = val
			}
		}

		if root != "" {
			if len(valuesNodeMap) == 0 {
				return []KeyPath{{
					Key:    root,
					Kind:   "map",
					IsNull: true,
				}}
			}
			res = append(res, KeyPath{
				Key:  root,
				Kind: "map",
			})
		}
		for key, val := range valuesNodeMap {
			nodeKeyMap := BuildValuesKeyList(path.Join(root, key), skipPaths, val)
			res = append(res, nodeKeyMap...)
		}
	default:
		fmt.Println("unknown values type:", kind)
	}

	return res
}

func GetSkipList(path string) (map[string][]string, error) {
	res := make(map[string][]string, 0)
	if path == "" {
		return res, nil
	}
	if _, err := os.Stat(path); errors.Is(err, os.ErrNotExist) {
		return res, nil
	}

	raw, err := os.ReadFile(path)
	if err != nil {
		return res, err
	}
	err = yaml.Unmarshal(raw, &res)
	if err != nil {
		return res, err
	}
	return res, nil
}
